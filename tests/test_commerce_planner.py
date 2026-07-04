"""Tests for ToolPlanner's e-commerce intent routing, including the
browse-catalog fallback for broad "what do you sell" style queries that
previously fell through to ungrounded general_chat."""

from unittest.mock import Mock

from backend.agents.node_calls import assistant_generation_node
from backend.tools.planner import ToolPlanner


def _plan_tool(message: str):
    planner = ToolPlanner()
    out = planner.plan(user_id="u1", user_message=message)
    return out.plan[0].tool if out.plan else None


def test_broad_browse_queries_route_to_browse_catalog():
    for message in [
        "你们有哪些商品",
        "介绍一下你们的商品",
        "what do you have",
        "what products do you sell",
        "show me your catalog",
    ]:
        assert _plan_tool(message) == "browse_catalog", message


def test_specific_queries_still_route_correctly():
    assert _plan_tool("帮我推荐一款手机") == "recommend_products"
    assert _plan_tool("降噪耳机多少钱") == "product_search"
    assert _plan_tool("P1002 有货吗") == "check_inventory"


def test_generic_buy_intent_still_routes_to_search():
    assert _plan_tool("我想买东西") == "product_search"


def test_need_based_queries_route_to_recommender():
    """A life-situation/need ("孩子刚出生","喜欢爬山") plus want-ish phrasing is
    a recommendation request even without an explicit "推荐"."""
    for message in [
        "我孩子刚出生，我作为一个单亲妈妈可以在这个店铺买些什么",
        "那我喜欢爬山，我可以在这个店铺买些什么呢",
        "我喜欢爬山",
        "有什么适合送长辈的",
        "我是一个孩子的妈妈，请问有什么可以给宝贝买的吗",
        "有什么可以给宝贝买的吗",
        "给娃买点什么好",
        "想给女儿买个礼物",
    ]:
        assert _plan_tool(message) == "recommend_products", message


def test_need_words_do_not_hijack_id_based_queries():
    # "耳机/手机" are need triggers, but a concrete product/SKU/order id means
    # the customer is after that object -- id branches must keep winning.
    assert _plan_tool("P1002 这个耳机有没有货") == "check_inventory"
    assert _plan_tool("SO20260012 物流到哪了") == "track_shipment"


def test_after_sales_phrasing_is_not_treated_as_shopping():
    # A broken past purchase mentions need triggers (手机/孩子) and want-ish
    # words, but it's after-sales -- recommending new products would be tone-deaf.
    assert _plan_tool("我买的手机坏了要退款") != "recommend_products"
    assert _plan_tool("孩子的推车坏了怎么换货") != "recommend_products"


def test_node_injects_pahf_memories_as_preference_context():
    """assistant_generation_node personalizes recommend_products with the
    customer's retrieved PAHF memories."""
    captured = {}

    class _CapturingExecutor:
        def execute_plan(self, user_id, plan):
            captured["plan"] = plan
            return []

    mock_model = Mock()
    mock_model.chat = Mock(return_value="ok")
    state = {
        "user_id": "u1",
        "user_message": "随便帮我推荐点东西",
        "retrieved_memories": [{"id": 1, "person_id": "u1", "text": "用户喜欢爬山和露营"}],
        "pahf_context_text": "",
        "clarification_question": None,
        "temperature": None,
        "max_tokens": None,
    }

    result = assistant_generation_node(
        state=state,
        model_client=mock_model,
        prompt_builder=None,
        prompt_scene="default",
        tool_planner=ToolPlanner(),
        tool_executor=_CapturingExecutor(),
        tool_registry=None,
        tools_enabled=True,
    )

    assert result["intent"] == "product_recommend"
    call = captured["plan"][0]
    assert call.tool == "recommend_products"
    assert "爬山" in call.arguments["preference_context"]

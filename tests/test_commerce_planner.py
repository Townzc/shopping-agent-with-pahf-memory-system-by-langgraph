"""Tests for ToolPlanner's e-commerce intent routing, including the
browse-catalog fallback for broad "what do you sell" style queries that
previously fell through to ungrounded general_chat."""

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

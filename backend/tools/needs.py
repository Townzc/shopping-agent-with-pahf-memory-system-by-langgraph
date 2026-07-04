"""Need/scenario rules shared by the planner (routing) and the recommender (scoring).

Maps what a customer *says about themselves or their situation* ("我孩子刚出生",
"我喜欢爬山") onto the catalog's actual categories and product vocabulary, so a
need-shaped message becomes a grounded recommendation instead of a fruitless
keyword search. Deterministic on purpose — same lightweight, testable style as
the rule planner; an LLM function-calling planner remains the long-term plan.
"""

from __future__ import annotations

from typing import Dict, List


# Each rule: `triggers` are phrases in the user's message that reveal the need;
# `boost` is catalog vocabulary (product title/description/attribute words) that
# the need should pull forward; `categories` get a ranking bonus. Boost words
# matter more than the category bonus so that e.g. a newborn need surfaces
# 奶瓶/推车 rather than the cat food that shares the 母婴宠物 category.
NEED_RULES: List[Dict] = [
    {
        "tag": "母婴育儿",
        "triggers": ["新生儿", "婴儿", "宝宝", "孩子", "小孩", "奶粉", "待产", "宝妈",
                     "妈妈", "哺乳", "母婴", "出生", "baby", "newborn", "infant"],
        "boost": ["婴儿", "奶瓶", "调奶", "推车", "拉拉裤", "尿裤", "恒温", "宽口"],
        "categories": ["母婴宠物"],
    },
    {
        "tag": "户外登山",
        "triggers": ["爬山", "登山", "徒步", "户外", "露营", "野营", "野外",
                     "hiking", "camping", "outdoor"],
        "boost": ["户外", "露营", "帐篷", "冲锋衣", "防潮", "头盔", "速干", "双肩包", "防水"],
        "categories": ["运动户外"],
    },
    {
        "tag": "健身运动",
        "triggers": ["健身", "跑步", "瑜伽", "锻炼", "减肥", "运动", "fitness", "workout", "gym"],
        "boost": ["哑铃", "瑜伽", "跑步", "速干", "运动", "缓震"],
        "categories": ["运动户外"],
    },
    {
        "tag": "养宠",
        "triggers": ["养猫", "养狗", "猫咪", "狗狗", "宠物", "猫粮", "铲屎", "cat", "dog", "pet"],
        "boost": ["猫粮", "猫砂", "宠物", "饮水机"],
        "categories": ["母婴宠物"],
    },
    {
        "tag": "办公通勤",
        "triggers": ["办公", "上班", "通勤", "工作", "出差", "职场", "office", "commute"],
        "boost": ["办公", "通勤", "键盘", "显示器", "衬衫", "双肩包", "拉杆箱", "文件", "护腕"],
        "categories": ["数码3C", "图书文具"],
    },
    {
        "tag": "数码科技",
        "triggers": ["手机", "电脑", "笔记本电脑", "数码", "耳机", "平板", "游戏", "打游戏"],
        "boost": ["手机", "笔记本", "耳机", "平板", "显示器", "路由", "快充", "键盘"],
        "categories": ["数码3C"],
    },
    {
        "tag": "美妆个护",
        "triggers": ["护肤", "化妆", "美妆", "皮肤", "敏感肌", "防晒", "洗脸", "skincare"],
        "boost": ["精华", "洁面", "防晒", "面膜", "保湿", "吹风机"],
        "categories": ["美妆个护"],
    },
    {
        "tag": "居家生活",
        "triggers": ["做饭", "厨房", "收纳", "打扫", "清洁", "居家", "搬家", "卧室", "新家"],
        "boost": ["收纳", "煎锅", "水壶", "吸尘", "毛巾", "净化", "四件套", "台灯"],
        "categories": ["家居日用"],
    },
    {
        "tag": "吃喝零食",
        "triggers": ["零食", "咖啡", "喝茶", "下午茶", "饮料", "解馋", "夜宵"],
        "boost": ["坚果", "咖啡", "乌龙茶", "燕麦"],
        "categories": ["食品饮料"],
    },
    {
        "tag": "学习文具",
        "triggers": ["学习", "读书", "写字", "文具", "考试", "学生", "上课"],
        "boost": ["笔记本", "中性笔", "文件架", "台灯", "鼠标垫"],
        "categories": ["图书文具"],
    },
    {
        "tag": "旅行出行",
        "triggers": ["旅行", "旅游", "出行", "度假", "travel"],
        "boost": ["拉杆箱", "双肩包", "速干", "快充", "防晒"],
        "categories": ["服饰鞋包"],
    },
]

# Flat trigger list for the planner's cheap "does this message express a need?" check.
ALL_NEED_TRIGGERS: List[str] = sorted({t for rule in NEED_RULES for t in rule["triggers"]})


def detect_needs(text: str) -> List[Dict]:
    """Return the NEED_RULES whose triggers appear in `text` (already any case)."""
    if not text:
        return []
    lowered = str(text).lower()
    return [rule for rule in NEED_RULES if any(t in lowered for t in rule["triggers"])]

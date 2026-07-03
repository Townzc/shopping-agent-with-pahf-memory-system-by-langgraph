from backend.tools.catalog_store import CatalogStore


def test_demo_catalog_has_rich_product_set(tmp_path):
    catalog = CatalogStore(db_path=str(tmp_path / "catalog.db"), auto_seed=True)

    products = catalog.list_products_for_admin(limit=100)
    categories = set(catalog.list_categories())

    assert len(products) >= 40
    assert categories == {"数码3C", "家居日用", "服饰鞋包", "美妆个护", "母婴宠物", "食品饮料", "运动户外", "图书文具"}
    assert catalog.demo_catalog_version()


def test_demo_catalog_keeps_core_after_sales_examples(tmp_path):
    catalog = CatalogStore(db_path=str(tmp_path / "catalog.db"), auto_seed=True)

    headphones = catalog.get_product("P1002")
    order = catalog.get_order("SO20260012")
    hits = catalog.search_products(query="降噪耳机", top_k=3)

    assert headphones is not None
    assert any(sku["sku_code"] == "P1002-WHT" for sku in headphones["variants"])
    assert order is not None
    assert order["items"][0]["sku_code"] == "P1002-WHT"
    assert hits and hits[0]["product_id"] == "P1002"

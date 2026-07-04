from backend.tools.catalog_store import CatalogStore
import pytest


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


def test_customer_registration_auth_and_admin_account_list(tmp_path):
    catalog = CatalogStore(db_path=str(tmp_path / "catalog.db"), auto_seed=True)

    customer = catalog.create_customer_account(
        customer_id="demo_buyer_01",
        password="StrongPwd2026",
        name="Demo Buyer",
        email="buyer@example.com",
        phone="13800000000",
    )

    assert customer["customer_id"] == "demo_buyer_01"
    assert catalog.authenticate_customer("demo_buyer_01", "StrongPwd2026")["name"] == "Demo Buyer"
    admin_rows = catalog.list_customer_accounts_for_admin(limit=100)
    assert any(row["account_type"] == "customer" and row["username"] == "demo_buyer_01" for row in admin_rows)

    with pytest.raises(ValueError):
        catalog.create_customer_account(
            customer_id="demo_buyer_01",
            password="StrongPwd2026",
            name="Duplicate Buyer",
        )


def test_cart_checkout_creates_pending_payment_order(tmp_path):
    catalog = CatalogStore(db_path=str(tmp_path / "catalog.db"), auto_seed=True)

    cart = catalog.add_cart_item(customer_id="c9001", product_id="P1002", qty=2)
    assert cart["item_count"] == 2
    assert len(cart["items"]) == 1
    assert cart["items"][0]["product_id"] == "P1002"

    order = catalog.checkout_cart(
        customer_id="c9001",
        shipping_address="Demo classroom address",
        shipping_method="Pending selection",
    )

    assert order["status"] == "pending_payment"
    assert order["total"] == cart["total"]
    assert order["items"][0]["qty"] == 2
    assert catalog.get_cart("c9001")["item_count"] == 0
    assert any(row["order_id"] == order["order_id"] for row in catalog.list_orders("c9001", limit=20))

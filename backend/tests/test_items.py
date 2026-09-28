from tests.conftest import register_and_login


def test_items_crud(client, auth_headers):
    res = client.post("/api/v1/items", json={"title": "Premier"}, headers=auth_headers)
    assert res.status_code == 201
    item = res.json()
    assert item["done"] is False

    res = client.get("/api/v1/items", headers=auth_headers)
    assert [i["id"] for i in res.json()] == [item["id"]]

    res = client.patch(
        f"/api/v1/items/{item['id']}", json={"done": True}, headers=auth_headers
    )
    assert res.json()["done"] is True
    assert res.json()["title"] == "Premier"

    res = client.delete(f"/api/v1/items/{item['id']}", headers=auth_headers)
    assert res.status_code == 204
    res = client.get(f"/api/v1/items/{item['id']}", headers=auth_headers)
    assert res.status_code == 404


def test_items_empty_title_rejected(client, auth_headers):
    res = client.post("/api/v1/items", json={"title": ""}, headers=auth_headers)
    assert res.status_code == 422


def test_items_are_private(client, auth_headers):
    item = client.post(
        "/api/v1/items", json={"title": "Secret"}, headers=auth_headers
    ).json()
    other = register_and_login(client, email="eve@example.com")

    assert client.get("/api/v1/items", headers=other).json() == []
    assert client.get(f"/api/v1/items/{item['id']}", headers=other).status_code == 404
    assert (
        client.patch(
            f"/api/v1/items/{item['id']}", json={"done": True}, headers=other
        ).status_code
        == 404
    )
    assert client.delete(f"/api/v1/items/{item['id']}", headers=other).status_code == 404

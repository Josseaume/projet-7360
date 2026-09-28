def test_register_and_login(client):
    res = client.post(
        "/api/v1/auth/register",
        json={"email": "Bob@Example.com", "password": "password123", "full_name": "Bob"},
    )
    assert res.status_code == 201
    assert res.json()["email"] == "bob@example.com"
    assert "hashed_password" not in res.json()

    res = client.post(
        "/api/v1/auth/login", json={"email": "bob@example.com", "password": "password123"}
    )
    assert res.status_code == 200
    assert res.json()["token_type"] == "bearer"


def test_register_duplicate_email(client):
    body = {"email": "bob@example.com", "password": "password123"}
    assert client.post("/api/v1/auth/register", json=body).status_code == 201
    assert client.post("/api/v1/auth/register", json=body).status_code == 409


def test_register_short_password(client):
    res = client.post(
        "/api/v1/auth/register", json={"email": "bob@example.com", "password": "short"}
    )
    assert res.status_code == 422


def test_login_wrong_password(client):
    client.post(
        "/api/v1/auth/register", json={"email": "bob@example.com", "password": "password123"}
    )
    res = client.post(
        "/api/v1/auth/login", json={"email": "bob@example.com", "password": "wrongpass1"}
    )
    assert res.status_code == 401


def test_token_form_for_swagger(client):
    client.post(
        "/api/v1/auth/register", json={"email": "bob@example.com", "password": "password123"}
    )
    res = client.post(
        "/api/v1/auth/token", data={"username": "bob@example.com", "password": "password123"}
    )
    assert res.status_code == 200


def test_me_requires_auth(client):
    assert client.get("/api/v1/users/me").status_code == 401
    bad = {"Authorization": "Bearer nimportequoi"}
    assert client.get("/api/v1/users/me", headers=bad).status_code == 401


def test_me_update_and_delete(client, auth_headers):
    res = client.get("/api/v1/users/me", headers=auth_headers)
    assert res.json()["full_name"] == "Alice"

    res = client.patch(
        "/api/v1/users/me", json={"full_name": "Alice D."}, headers=auth_headers
    )
    assert res.json()["full_name"] == "Alice D."

    assert client.delete("/api/v1/users/me", headers=auth_headers).status_code == 204
    assert client.get("/api/v1/users/me", headers=auth_headers).status_code == 401

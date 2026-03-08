import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_route(client):
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert data['service'] == "Nexus Platform Sample Microservice"
    assert data['status'] == "healthy"
    assert 'requests_handled' in data

def test_health_route(client):
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == "healthy"

def test_metrics_route(client):
    response = client.get('/metrics')
    assert response.status_code == 200
    data = response.get_json()
    assert 'requests_total' in data
    assert 'error_rate' in data
    assert 'response_time_ms' in data
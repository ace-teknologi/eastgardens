from eastgardens import eastgardens
import variables


def test_eastgardens_vanilla():
    variables.HOST = 'test.com'
    response = eastgardens(
        {'Records': [{'cf': {'request': {'uri': '/thing', 'querystring': ''}}}]}, None)
    assert response == {'headers': {'location': [
        {'key': 'Location', 'value': '//test.com/thing'}]}, 'status': '302', 'statusDescription': 'Found'}


def test_eastgardens_origin():
    variables.REDIRECTS = {'/nah-man': 'https://somewhere.com/wut'}
    variables.FALLTHROUGH = 'origin'
    response = eastgardens(
        {'Records': [{'cf': {'request': {'uri': '/thing', 'otherstuff': 'yeah', 'querystring': ''}}}]}, None)
    assert response == {'uri': '/thing',
                        'otherstuff': 'yeah', 'querystring': ''}


def test_eastgarders_redirects():
    variables.REDIRECTS = {'/a-hit': 'https://great-site.com/kitten-videos'}
    response = eastgardens(
        {'Records': [{'cf': {'request': {'uri': '/a-hit', 'otherstuff': 'yeah', 'querystring': ''}}}]}, None)
    assert response == {'headers': {'location': [
        {'key': 'Location', 'value': 'https://great-site.com/kitten-videos'}]}, 'status': '302', 'statusDescription': 'Found'}

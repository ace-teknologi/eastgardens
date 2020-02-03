import json

REDIRECTS = {
    ${custom_redirects}
}

def eastgardens(event, context):
    """
    Generate HTTP redirect response with 302 status code and Location header.
    """

    path = event['Records'][0]['cf']['request']['uri']

    redirect = '//${host}' + path

    if path in REDIRECTS:
        redirect = REDIRECTS[path]

    return {
        'status': '302',
        'statusDescription': 'Found',
        'headers': {
            'location': [{
                'key': 'Location',
                'value': redirect
            }]
        }
    }

def test():
    event = {'Records':[{'cf':{'request':{'uri': '/blah'}}}]}
    resp = eastgardens(event, None)
    print(resp)

    event = {'Records':[{'cf':{'request':{'uri': '/a-special-redirect'}}}]}
    resp = eastgardens(event, None)
    print(resp)

test()

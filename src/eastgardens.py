import json

import variables


def eastgardens(event, context):
    """
    Generate HTTP redirect responses
    """

    request = event['Records'][0]['cf']['request']
    path = request['uri']
    query = request['querystring']

    # prepend a ? if there is a query
    if query != '':
        query = '?' + query

    # Check if we have hit a custom redirect
    if path in variables.REDIRECTS:
        return redirect(variables.REDIRECTS[path])

    # We also support path+query based custom redirects
    if path + query in variables.REDIRECTS:
        return redirect(variables.REDIRECTS(path + query))

    # If no fallthough response provider, 302 the whole website to the HOST that
    # was input
    if variables.FALLTHROUGH == '':
        return redirect('//' + variables.HOST + path + query)
    # If we asked to fallthrough to the origin, just return the original request
    # so that Cloudfront continues on its merry way
    elif variables.FALLTHROUGH == 'origin':
        return event['Records'][0]['cf']['request']
    # Otherwise use the fallthrough as is
    else:
        return variables.FALLTHROUGH


def redirect(target):
    """
    Returns a redirect map to the target provided
    """
    return {
        'status': '302',
        'statusDescription': 'Found',
        'headers': {
            'location': [{
                'key': 'Location',
                'value': target
            }]
        }
    }

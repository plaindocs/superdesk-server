
from superdesk.resource import Resource
from apps.content import metadata_schema
from apps.archive.common import item_url
ASSOCIATIONS = 'associations'
ITEM_REF = 'itemRef'


class PackageResource(Resource):
    '''
    Package schema
    '''
    datasource = {
        'source': 'archive',
        'default_sort': [('_updated', -1)],
        'filter': {'type': 'composite'},
        'elastic_filter': {'term': {'archive.type': 'composite'}}  # eve-elastic specific filter
    }
    item_url = item_url
    item_methods = ['GET', 'PATCH']

    schema = {}
    schema.update(metadata_schema)
    schema.update({
        'type': {
            'type': 'string',
            'readonly': True,
            'default': 'composite'
        },
        'groups': {
            'type': 'list',
            'minlength': 1,
            'schema': {
                'type': 'dict',
                'schema': {
                    'group': {
                        'role': {
                            'type': 'string',
                            'required': True
                        },
                        'id': {
                            'type': 'string'
                        },
                        ASSOCIATIONS: {
                            'type': 'list',
                            'required': True,
                            'minlength': 1,
                            'schema': {
                                'type': 'dict',
                                'schema': {
                                    ITEM_REF: {'type': 'string'},
                                    'guid': {
                                        'type': 'string',
                                        'readonly': True
                                    },
                                    'version': {
                                        'type': 'string',
                                        'readonly': True
                                    },
                                    'type': {
                                        'type': 'string',
                                        'readonly': True
                                    },
                                    'slugline': {'type': 'string'},
                                    'headline': {'type': 'string'},
                                }
                            }
                        }
                    }
                }
            }
        },
        'profile': {
            'type': 'string'
        }
    })

    privileges = {'POST': 'archive', 'PATCH': 'archive'}

from ..models.item import ItemModel
from superdesk import SuperdeskError
from superdesk.utc import utcnow
from superdesk.notification import push_notification
from apps.common.components.base_component import BaseComponent
from apps.common.models.utils import get_model
import superdesk


LOCK_USER = 'lock_user'
LOCK_SESSION = 'lock_session'
STATUS = '_status'


def can_lock(item, user):
    # TODO: implement
    return True


class ItemLock(BaseComponent):
    def __init__(self, app):
        self.app = app

    @classmethod
    def name(cls):
        return 'item_lock'

    def lock(self, filter, user, session, etag):
        item_model = get_model(ItemModel)
        item = item_model.find_one(filter)
        if item and can_lock(item, user):
            self.app.on_item_lock(item, user)
            updates = {LOCK_USER: user, LOCK_SESSION: session, 'lock_time': utcnow()}
            item_model.update(filter, updates)
            superdesk.get_resource_service('tasks').assign_user(item['_id'], user)
            self.app.on_item_locked(item, user)
            push_notification('item:lock', item=str(item.get('_id')), user=str(user))
        else:
            raise SuperdeskError('Item locked by another user')
        item = item_model.find_one(filter)
        return item

    def unlock(self, filter, user, session, etag):
        item_model = get_model(ItemModel)
        item = item_model.find_one(filter)
        if item:
            self.app.on_item_unlock(item, user)
            updates = {LOCK_USER: None, LOCK_SESSION: None, 'lock_time': None, 'force_unlock': True}
            item_model.update(filter, updates)
            self.app.on_item_unlocked(item, user)
            push_notification('item:unlock', item=str(filter.get('_id')), user=str(user))
        item = item_model.find_one(filter)
        return item

from eve.io.mongo.media import GridFSMediaStorage
import logging
from bson import ObjectId
from superdesk.media_operations import get_hashed_filename
from gridfs import GridFS


logger = logging.getLogger(__name__)


class SuperdeskGridFSMediaStorage(GridFSMediaStorage):

    def get(self, _id):
        logger.debug('Getting media file with id= %s' % _id)
        if isinstance(_id, str):
            _id = ObjectId(_id)
        return super().get(_id)

    def put(self, content, filename=None, content_type=None):
        file_name, out, content_type = get_hashed_filename(content, filename, content_type)
        logger.debug('Going to save media file with %s ' % file_name)

        _id = self.fs().put(out, content_type=content_type, filename=file_name)
        logger.debug('Saved  media file with id= %s' % _id)
        return _id

    def fs(self):
        if self._fs is None:
            self._fs = GridFS(self.app.data.mongo.driver.db)
        return self._fs

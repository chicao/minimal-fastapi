import logging
import httpx
import json

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

url = 'http://172.17.0.2:8000'
endpoint = '/items'
headers = {
    'User-Agent': 'minimal-fastapi.populate',
    'Content-Type': 'application/json',
}

items = [
    {
        'name': 'Item 1',
        'price': 1,
        'is_offer': True,
    },
    {
        'name': 'Item 2',
        'price': 2,
        'is_offer': False,
    },
    {
        'name': 'Item 3',
        'price': 3,
        'is_offer': True,
    },
    {
        'name': 'Item 2',
        'price': 4,
        'is_offer': False,
    },
]

logger.info('Add boilerplate content into the API')
id = 1
for item in items:
    logger.info(f'Adding item {item['name']}')
    request = httpx.put(
        url+endpoint+f'/{id}',
        data=json.dumps(item),
        headers=headers
        )
    logger.info(f'Done with item id={id}')
    id+=1

logger.info('Finished')
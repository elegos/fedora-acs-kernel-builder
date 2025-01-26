from argparse import ArgumentParser

import re
from typing import Optional
import urllib.request

import xml.etree.ElementTree

kernel_name_regex = re.compile(r'.?kernel-(\d+)\.(\d+)\.(\d+)-(\d+)\.fc(\d+).?')

def get_latest_kernel_version(fedora_ver: int, stable_only: bool = True) -> Optional[str]:
    feed_url = f'https://bodhi.fedoraproject.org/rss/updates/?search=kernel-&releases=F{fedora_ver}'

    with urllib.request.urlopen(feed_url) as f:
        content : str = f.read().decode('utf-8')

        root = xml.etree.ElementTree.fromstring(content)
        channel = root.find('channel')

        if channel is None:
            raise Exception('Invalid RSS feed')
        
        items = []
        for item in channel.findall('item'):
            match = kernel_name_regex.match(item.find('title').text)

            if match and match.group(5) == fedora_ver:
                items.append({
                    'kernel_major': int(match.group(1)),
                    'kernel_minor': int(match.group(2)),
                    'kernel_patch': int(match.group(3)),
                    'kernel_release': int(match.group(4)),
                    'description': item.find('description').text
                })

        # It probably needs some tweaks
        if stable_only:
            items = [item for item in items if 'stable' in item['description']]

        if len(items) == 0:
            return None

        items.sort(
            key=lambda item: (item['kernel_major'], item['kernel_minor'], item['kernel_patch'], item['kernel_release']),
            reverse=True,
        )
        
        major = items[0]['kernel_major']
        minor = items[0]['kernel_minor']
        patch = items[0]['kernel_patch']
        release = items[0]['kernel_release']

        return f'{major}.{minor}.{patch}-{release}'


def main():
    args = ArgumentParser()
    args.add_argument('fedora_ver', nargs='?', default='41')

    args = args.parse_args()

    latest_version = get_latest_kernel_version(args.fedora_ver)

    if latest_version is None:
        raise Exception('No kernel found!')
    
    print(latest_version)


if __name__ == '__main__':
    main()
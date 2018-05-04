import sys
from itertools import permutations
from random import shuffle

from celery import group

from sorting_task import bad_sort

def random_integers(size):
    items = list(range(size))
    shuffle(items)
    return items

def main():
    difficulty = 10
    num_tasks = 50

    job = group([bad_sort.s(random_integers(difficulty))
                 for _ in range(num_tasks)])
    result = job.apply_async()
    print("Waiting...")
    result.get(callback=print)
    print("Done!")

if __name__ == '__main__':
    main()

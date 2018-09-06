import argparse
import codecs
import itertools
import os
import re
import sys

class_re = re.compile(r'class ([^{:]+?)(: [^\s]+)? {\n([^}]+?})', re.DOTALL)
var_re = re.compile(r'(((\s\s\s\s)|\t)(@NSManaged )?var ([^:]+): ([^\n\s]+)( = ([^\n]+?))?)\n', re.DOTALL)

parser = argparse.ArgumentParser(description='Check validity of models.')
parser.add_argument('-p', '--path', help='Path to the models directory.', dest='path')
parser.add_argument('-e', '--error', help='Treat as error.', dest='error', action='store_true')

args = parser.parse_args()
classes = {}
prefixes = ['App', 'DB', 'Net']


# noinspection PyShadowingNames
def extract(class_name):
    global prefixes

    for prf in prefixes:
        if class_name.startswith(prf):
            return prf, class_name.split(prf)[1]

    return None


def line_for_str(string, text):
    for (index, line) in enumerate(text.split('\n')):
        if string in line:
            return index + 1

    return None


for root, dirs, files in os.walk(args.path):
    for file_name in files:
        path = os.path.join(root, file_name)

        if not file_name.endswith('.swift'):
            continue

        f = codecs.open(path, mode='r', encoding='utf-8')
        content = f.read()
        f.close()

        for class_match in class_re.findall(content):
            pair = extract(class_match[0])
            if pair:
                prefix, name = pair

                if name not in classes:
                    classes[name] = {}

                if prefix not in classes[name]:
                    classes[name][prefix] = {'__path__': path}

                for variable_match in var_re.findall(class_match[2]):
                    classes[name][prefix][variable_match[4]] = {'type': variable_match[5],
                                                                '__line__': line_for_str(variable_match[0], content)}
had_error = False
for class_name, content in classes.iteritems():
    for first, second in itertools.combinations(content.keys(), 2):
        first_keys = content[first].keys()
        second_keys = content[second].keys()

        fr, sn = first, second
        if len(first_keys) < len(second_keys):
            fr, sn = second, first
            first_keys, second_keys = second_keys, first_keys

        for first_var in first_keys:
            if first_var.startswith('__'):
                continue

            passed = False
            for second_var in second_keys:
                if first_var == second_var:
                    passed = True
                    break

            if not passed:
                had_error = True
                print('{}:{}: {}: Inconsistency found at {}'.format(content[fr]['__path__'],
                                                                    content[fr][first_var]['__line__'],
                                                                    'error' if args.error else 'warning', first_var))

sys.exit(-1 if had_error and args.error else 0)

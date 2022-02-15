import glob
import re

file_types = ('*.h', '*.cpp', '*.tex')


def get_source_files(base_directory):
    """Function recursively crawlers files in base directory and returns c++ source files"""
    source_files = [];
    for file_type in file_types:
        for filename in glob.iglob(base_directory + '/**/' + file_type, recursive=True):
            source_files.append(filename)
    return source_files


def get_file_content(filename):
    """Function to get file content"""
    with open(filename, 'r') as f:
        return f.readlines()


def remove_last_space(str_my):
    if str_my.endswith(' '):
        return remove_last_space(str_my[:-1])
    return str_my


def remove_comment(str_my):
    start_of_comment = -1
    has_comment = False
    index = 0
    for letter in str_my:
        if letter == '/' and start_of_comment != -1:
            has_comment = True
            break
        elif letter == '/':
            start_of_comment = index
        elif start_of_comment != -1:
            start_of_comment = -1
        index = index + 1

    if has_comment:
        return str_my[:index - 1]
    return str_my


def get_open_mp_directives(filename):
    """Function to get OpenMP directives from source as tuple (directive + line)"""
    # print(filename)
    lines = get_file_content(filename)
    pragma_lines = []
    for line in lines:
        mm = re.match(r'(?<!//).*(#pragma\somp[\w\s()+-:=,><&|]+)', line, re.M | re.I)
        if mm:
            declaration = remove_last_space(remove_comment(mm.group(1).replace("\n", "")))
            # print(declaration)
            pragma_lines.append(declaration)
    return set(pragma_lines)


def write_to_file(filename, set):
    file = open(filename, "w")
    for line in set:
        file.write(line + '\n')


def crawler_directory_and_process_directives(base_directory, file_to_write_in):
    """Crawl recursively base directory and find all openmp directives in sources."""
    source_files = get_source_files(base_directory)
    ls = []
    for file in source_files:
        ls.append(get_open_mp_directives(file))
    set_of_directives = set([item for sublist in ls for item in sublist])
    write_to_file(file_to_write_in, set_of_directives)
    print('Crawling complete. Found', len(set_of_directives), 'unique directives. Consider checking them for correctness.')

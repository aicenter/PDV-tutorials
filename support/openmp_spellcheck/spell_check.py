import argparse

from file_manager import crawler_directory_and_process_directives
from spell_checker import build_syntax_tree, spell_check_file


def main():
    # arguments...
    parser = argparse.ArgumentParser(description='OpenMP spellchecker', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('--crawler', action='store_true', help="Crawler C++ sources to build OpenMP dictionary.")
    parser.add_argument('--directory', type=str, help="Base directory to crawl for C++ sources.")
    parser.add_argument('--dictionary', type=str, help="Dictionary to use for C++ sources.")
    parser.add_argument('--file', type=str, help="File to spell-check.")
    args = parser.parse_args()

    if args.crawler:
        if not args.directory or not args.dictionary:
            print('Provide directory to crawl and output directory for dictionary.')
        else:
            crawler_directory_and_process_directives(args.directory, args.dictionary)
    else:
        if not args.dictionary or not args.file:
            print('Provide dictionary and source file to check.')
        else:
            root = build_syntax_tree(args.dictionary)
            for warning in spell_check_file(args.file, root):
                print(warning)


if __name__ == "__main__":
    main()

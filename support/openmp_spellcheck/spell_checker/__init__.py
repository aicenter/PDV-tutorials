from file_manager import get_file_content, get_open_mp_directives


def get_index_of_closing_bracket(str_my, index):
    if len(str_my) <= index:
        if str_my[index - 1] != ')':
            return -1
        return index
    if str_my[index] == '(':
        index = get_index_of_closing_bracket(str_my, index + 1)
        return get_index_of_closing_bracket(str_my, index + 1)
    if str_my[index] == ')':
        return index
    return get_index_of_closing_bracket(str_my, index + 1)


def remove_spaces_from_start(str_my):
    if len(str_my) == 0:
        return ''
    if str_my[0] == ' ':
        return remove_spaces_from_start(str_my[1:])
    return str_my


def skip_to_closing_bracket(str_my):
    if len(str_my) == 0 or str_my[0] != '(':
        return str_my
    index = get_index_of_closing_bracket(str_my, 1)
    return str_my[index + 1:]


def skip_to_next_space_or_bracket(str_my, index):
    if len(str_my) <= index or str_my[index] == '(' or str_my[index] == ' ':
        return str_my[:index], str_my[index:]
    return skip_to_next_space_or_bracket(str_my, index + 1)


class Node:
    def __init__(self):
        self.is_terminal = False
        self.d = dict()

    def add_exp(self, my_str):
        new_str = remove_spaces_from_start(my_str)
        if not new_str or len(new_str) == 0:
            self.is_terminal = True
            return
        if new_str[0] == '(':
            str_next = skip_to_closing_bracket(new_str)
            key = '('
            value = str_next
        else:
            pair = skip_to_next_space_or_bracket(new_str, 0)
            key = pair[0]
            value = pair[1]

        # add new associations
        if key in self.d:
            node = self.d[key]
        else:
            node = Node()
            self.d[key] = node
        node.add_exp(value)

    def print_path(self, str_previous):
        if self.is_terminal:
            print(str_previous)
        if len(self.d) > 0:
            for key, value in self.d.items():
                value.print_path(str_previous + " " + key)

    def recognized(self, my_str, original):
        if not my_str or len(my_str) == 0:
            return True, ''
        new_str = remove_spaces_from_start(my_str)
        if not new_str or len(new_str) == 0:
            return True, ''
        if new_str[0] == '(':
            if get_index_of_closing_bracket(new_str, 1) == -1:
                return False, 'Pravdepodobne chybi uzaviraci zavorka v \'' + original + '\''
            str_next = skip_to_closing_bracket(new_str)
            key = '('
            value = str_next
        else:
            pair = skip_to_next_space_or_bracket(new_str, 0)
            key = pair[0]
            value = pair[1]
        if key in self.d:
            node = self.d[key]
            return node.recognized(value, original)
        else:
            return False, 'Nerozpoznano: \'' + key + '\' v \'' + original + '\''


def build_syntax_tree(filename):
    lines = get_file_content(filename)
    root = Node()
    for line in lines:
        root.add_exp(line.replace("\n", ""))
    return root


def spell_check_file(filename, root):
    directives = get_open_mp_directives(filename)
    return [e[1] for e in [root.recognized(directive, directive) for directive in directives] if e[0] is False]

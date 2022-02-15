#include <omp.h>
#include <limits>
#include <algorithm>
#include "bfs_orig.h"
#include <atomic>
#include <iostream>
#include <map>

//simple greedy method to balance frontiers - difference in size of frontiers should be most "difference_to_move"
//zkouším češtinu
const unsigned long difference_to_move = 20;
const unsigned long minimum_nodes_per_thread = 100;

class fake_state : public state {
public:
    fake_state(unsigned int cost) : state(std::shared_ptr<state>(), cost) {}

    std::vector<std::shared_ptr<const state>> next_states() const override {
        return {};
    }

    bool is_goal() const override {
        return false;
    }

    unsigned long long int get_identifier() const override {
        return 0;
    }

    std::string to_string() const override {
        return "";
    }
};

class element {
public:
    element *predecessor;
    std::shared_ptr<const state> value;

    element(std::shared_ptr<const state> &value) : value(value), predecessor(nullptr) {}

    element(std::shared_ptr<const state> &value, element *predecessor) : value(value), predecessor(predecessor) {}
};

class my_list {
private:
    element *head;
    element *tail;
    unsigned long size;

    my_list(element *start, element *end, unsigned long count) {
        head = start;
        tail = end;
        size = count;
    }

public:
    my_list() {
        head = nullptr;
        tail = nullptr;
        size = 0;
    }

    my_list(element *single) {
        head = single;
        tail = single;
        size = 1;
    }

    void addNode(std::shared_ptr<const state> &value) {
        auto el = new element(value, tail);
        if (head == nullptr) {
            head = el;
        }
        tail = el;
        size++;
    }

    void mergeAndInvalidate(my_list &list) {
        if (!list.empty()) {
            size = size + list.size;
            list.head->predecessor = tail;
            tail = list.tail;

            if (head == nullptr) {
                head = list.head;
            }

            //invalidate old list
            list.size = 0;
            list.head = nullptr;
            list.tail = nullptr;
        }
    }

    bool empty() {
        return size <= 0;
    }

    unsigned long getSize() {
        return size;
    }

    my_list move(unsigned long count) {

        //return empty list
        if (count <= 0) {
            return {};
        }

        element *start = nullptr;
        element *end = tail;
        unsigned long to_get = std::min(count, size);

        //find start
        for (int i = 0; i < count; ++i) {
            start = tail;
            tail = tail->predecessor;
        }

        start->predecessor = nullptr;
        size = size - to_get;
        return {start, end, to_get};
    }

    void clear() {
        while (tail != nullptr) {
            pop();
        }
    }

    element *front() {
        return tail;
    }

    void pop() {
        if (tail != nullptr) {
            element *old = tail;
            tail = tail->predecessor;
            size--;
            if (size == 0) {
                head = nullptr;
            }
            delete (old);
        }
    }

};

unsigned long balance_frontiers(std::vector<my_list> &frontier, const unsigned long lists, const unsigned long nodes) {

    //is there enough work for current count of threads
    unsigned long nodes_per_thread = nodes / lists;
    if (lists > 1 && nodes_per_thread < minimum_nodes_per_thread) {
        my_list list = frontier[lists - 1].move(frontier[lists - 1].getSize());
        frontier[0].mergeAndInvalidate(list);
        return balance_frontiers(frontier, lists - 1, nodes);
    }

    auto biggest_queue = std::max_element(std::begin(frontier), std::begin(frontier) + lists,
                                          [&](my_list first, my_list second) {
                                              return first.getSize() < second.getSize();
                                          });
    auto smallest_queue = std::min_element(std::begin(frontier), std::begin(frontier) + lists,
                                           [&](my_list first, my_list second) {
                                               return first.getSize() < second.getSize();
                                           });

    unsigned long difference = biggest_queue->getSize() - smallest_queue->getSize();
    if (difference > difference_to_move) {
        unsigned long move = difference / 2;
        my_list list = biggest_queue->move(move);
        smallest_queue->mergeAndInvalidate(list);
        return balance_frontiers(frontier, lists, nodes);
    }
    return lists;
}

bool should_expand_node(std::map<const unsigned long long, std::shared_ptr<const state>> &prices,
                        std::shared_ptr<const state> &node) {
    if (prices.count(node->get_identifier()) != 0) {
        auto value = prices[node->get_identifier()];
        if (value != nullptr && value->current_cost() <= node->current_cost()) {
            return false;
        }
    }
    return true;
}

bool should_expand_node(std::vector<std::map<const unsigned long long, std::shared_ptr<const state>>> &prices,
                        std::shared_ptr<const state> &node, const int thread_id) {
    unsigned long size = prices.size();
    for (int i = 0; i < size; ++i) {
        if (i != thread_id && prices[i].count(node->get_identifier()) != 0) {
            auto value = prices[i][node->get_identifier()];

            //this may cause that same node will be expanded more then once
            if (value != nullptr && value->current_cost() < node->current_cost()) {
                return false;
            } else if (value->current_cost() == node->current_cost() && i < thread_id) {
                return false;
            }
        }
    }
    return true;
}

bool is_frontier_empty(std::vector<my_list> &frontier) {
    unsigned long size = frontier.size();
    for (int i = 0; i < size; ++i) {
        if (!frontier[i].empty()) {
            return false;
        }
    }
    return true;
}

void
par_bfs_search_worker(std::vector<my_list> &frontier, std::vector<my_list> &new_frontier,
                      std::shared_ptr<const state> *glob_opt, const std::shared_ptr<const state> &root) {
    unsigned long number_of_threads = frontier.size();
    unsigned long nodes = frontier[0].getSize();
    for (int i = 1; i < number_of_threads; ++i) {
        nodes = nodes + frontier[i].getSize();
    }
    number_of_threads = balance_frontiers(frontier, number_of_threads, nodes);
    std::vector<std::map<const unsigned long long, std::shared_ptr<const state>>> prices(number_of_threads);
    omp_set_num_threads(number_of_threads);
    std::atomic<bool> found{false};

#pragma omp parallel
    {
        const int thread_id = omp_get_thread_num();
        my_list *my_frontier = &frontier[thread_id];
        my_list *my_new_frontier = &new_frontier[thread_id];
        std::map<const unsigned long long, std::shared_ptr<const state>> *my_price_map = &prices[thread_id];
        auto curr_opt = atomic_load(glob_opt);

        while (!my_frontier->empty()) {
            auto to_expand = my_frontier->front()->value;
            (*my_frontier).pop();
            for (auto &&next : to_expand->next_states()) {
                if (found) {
                    break;
                }

                std::shared_ptr<const state> s = next;
                //do not expand same nodes, assuming cost is equal or greater
                if (s->get_identifier() != root->get_identifier() &&
                    s->get_identifier() != to_expand->get_identifier()) {

                    //do we have solution?
                    if (s->is_goal()) {
                        while (s->current_cost() < curr_opt->current_cost()) {
                            if (atomic_compare_exchange_strong(glob_opt, &curr_opt, s)) {
//                                std::cout << "Found goal: " << s->current_cost() << std::endl;
                                found = true;
                                break;
                            }
                        }
                        continue;
                    } else if (should_expand_node(*my_price_map, s)) {
                        (*my_price_map)[s->get_identifier()] = s;
                    }
                }
            }
        }

#pragma omp barrier

        if (!found) {
            //filter nodes to expand
            for (auto &iter : *my_price_map) {
                auto node = iter.second;
                if (!should_expand_node(prices, node, thread_id)) {
                    continue;
                }

                //add to queue
                my_new_frontier->addNode(node);
            }
        }
    }
}

unsigned long compute_breadth(std::vector<my_list> &frontier) {
    unsigned long int breadth = 0;
    unsigned long int size = frontier.size();
    for (int i = 0; i < size; ++i) {
        breadth = breadth + frontier[i].getSize();
    }
    return breadth;
}

std::shared_ptr<const state> bfs(std::shared_ptr<const state> root) {

    if (root->is_goal()) {
        return std::shared_ptr<const state>{};
    }

    const int threads = omp_get_max_threads();
    std::vector<my_list> frontier(threads);
    std::vector<my_list> new_frontier(threads);
    std::shared_ptr<const state> glob_opt = std::make_shared<fake_state>(std::numeric_limits<unsigned int>::max());

    std::shared_ptr<const state> root_c = root;

    //init first frontier
    frontier[0].addNode(root_c);

//    unsigned long int depth = 1;
//    unsigned long int breadth;

    while (!is_frontier_empty(frontier)) {
        par_bfs_search_worker(frontier, new_frontier, &glob_opt, root_c);
        frontier.swap(new_frontier);
//        breadth = compute_breadth(frontier);
//        std::cout << "Searching depth " << depth++ << " with breadth " << breadth << std::endl;
    }

    if (!glob_opt->is_goal()) {
        return std::shared_ptr<const state>{};
    }
    return glob_opt;
}

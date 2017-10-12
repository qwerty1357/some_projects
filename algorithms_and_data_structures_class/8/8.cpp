#include <iostream>
#include <tuple>
#include <vector>
#include <list>
#include <iterator>

using namespace std;


struct node {
    long key;
    long x;
    long y;
    node *left;
    node *right;
};

// struktura do zbierania tymczasowych wartości, przy wstawianiu
struct temp_nodes {
    long key;
    long x;
    long y;
};


long temp;

long counter = 0;;

long T[100001][5];

long TRIP[1000001][3];

long A[100001][3]; // position after only one move from (0,0)

long max_value = 10;

long flunkey1, flunkey2;

struct temp_nodes temp_node;


// Creates range tree to get proper order
void create_tree(int h, struct node *n, long number_of_leaf) {
    number_of_leaf /= 2;
    if (h > 0) {
        n->left = new node;
        n->left->key = number_of_leaf;
        n->left->left = NULL;
        n->left->right = NULL;
        n->right = new node;
        n->right->key = number_of_leaf;
        n->right->left = NULL;
        n->right->right = NULL;
        h = h - 1;
        create_tree(h, n->left, number_of_leaf);
        create_tree(h, n->right, number_of_leaf);
    }
}


// Prints tree to array in proper order
void print_tree(struct node *n) {
    if (n != NULL) {
        print_tree(n->left);
        print_tree(n->right);
        if ((n->left != NULL) && (n->right == NULL)) {
            T[counter][3] = n->left->key;
            counter++;
        }
    }
}


// Removes additional leaves; Adds max value in each leaf.
void change_values_in_tree(struct node *n) {
    if (n != NULL) {
        //n->key = max_value;
        change_values_in_tree(n->left);
        change_values_in_tree(n->right);
        if ((n->left != NULL) && (n->right == NULL)) {
            free(n->left);
            n->left = NULL;
        }
    }
}


// Insertion to tree, to count where is he after gets a hint
void insert_on_position(long value, long position, long leaves, int h, struct node *n) {
    long f2 = leaves;
    while (h > 0) {
        leaves = leaves / 2;
        if (n->key > value) {
            n->key = value;
        }
        if (f2 - leaves < position) {
            n = n->right;
        } else {
            n = n->left;
            f2 = f2 - leaves;
        }
        h--;
    }
    n->key = value;
}


// Wypełniam drzewo wartościami z punktu (0,0)
void prepare_tree_to_hints(struct node *n) {
    if (n != NULL) {
        n->key = 0;
        n->x = 0;
        n->y = 0;
        prepare_tree_to_hints(n->left);
        prepare_tree_to_hints(n->right);
    }
}


// Determinates proper order of hints.
void insert(long value, struct node *n, int H, long to_insert) {
    // to_insert - first number in reverse order
    while (H > 0) {
        if (n->left->key >= value) {
            n = n->left;
            n->key--;
        } else {
            value = value - n->left->key;
            n = n->right;
            n->key--;
        }
        H--;
    }
    n->left = new node;
    n->left->key = to_insert;
    n->left->left = NULL;
    n->left->right = NULL;
}


// Merges states from left and right node
void merges_two_hints(struct node *n) {
    n->x = n->left->x;
    n->y = n->left->y;
    // 0 - prawo, 1 - góra, 2 - lewo, 3 - dół
    switch (n->left->key) {
        case 1:
            n->x += n->right->y;
            n->y -= n->right->x;
            break;
        case 3:
            n->x -= n->right->y;
            n->y += n->right->x;
            break;
        case 0:
            n->x += n->right->x;
            n->y += n->right->y;
            break;
        case 2:
            n->x -= n->right->x;
            n->y -= n->right->y;
            break;
    }
    n->key = (n->left->key + n->right->key) % 4;
}


void adds_from_left_nodes(struct node *n) {
    switch (temp_node.key) {
        case 1:
            temp_node.x += n->y;
            temp_node.y -= n->x;
            break;
        case 3:
            temp_node.x -= n->y;
            temp_node.y += n->x;
            break;
        case 0:
            temp_node.x += n->x;
            temp_node.y += n->y;
            break;
        case 2:
            temp_node.x -= n->x;
            temp_node.y -= n->y;
            break;
    }
    temp_node.key = (temp_node.key + n->key) % 4;
}


void inserts_on_position_and_updates_nodes(long value, long position, long leaves, int h, struct node *n, int f1, int f2) {
    if (h > 0) {
        leaves = leaves / 2;
        if (position <= f2 - leaves) { // ide do lewego synka
            f2 = f2 - leaves;
            --h;
            inserts_on_position_and_updates_nodes(value, position, leaves, h, n->left, f1, f2);
        } else { // ide do prawego synka
            f1 = f1 + leaves;
            adds_from_left_nodes(n->left);
            --h;
            inserts_on_position_and_updates_nodes(value, position, leaves, h, n->right, f1, f2);
        }
        merges_two_hints(n);
    } else {
        n->key = A[value][0];
        n->x = A[value][1];
        n->y = A[value][2];
        adds_from_left_nodes(n);
    }
}


void print_coordinates() {
    cout << temp_node.x << " " << temp_node.y << endl;
}


int main() {
    long n, i = 1, l;
    int  h = 0;
    cin >> n;
    max_value = n + 1;
    temp = -1;
    counter = 1;
    char direction;
    struct node *root;
    root = new node;

    while (i < n) {
        h++;
        i *= 2;
    }

    l = i;
    flunkey1 = 1;
    flunkey2 = i;
    root->key = i;
    root->left = NULL;
    root->right = NULL;

    create_tree(h, root, i);

    for (long t = 1; t <= n; t++) {
        cin >> T[t][0];
        cin >> direction;
        if (direction == 'L') {
            T[t][1] = 3;
        } else if (direction == 'R') {
            T[t][1] = 1;
        } else {
            T[t][1] = 2;
        }
        cin >> T[t][2];
    }

    for (long r = n; r >= 1; r--) {
        insert(T[r][0], root, h, r);
    }

    print_tree(root); // Wypisanie w dobrej kolejności do tablicy T

    change_values_in_tree(root);

    for (long i = 1; i <= n; i++) {
        if (T[i][1] == 3) { // ide w lewo
            A[i][0] = 3; // to na kierunek
            A[i][1] -= T[i][2]; // to na x
            A[i][2] = 0; // to na y
        } else if (T[i][1] == 1) { // ide w prawo
            A[i][0] = 1;
            A[i][1] += T[i][2];
            A[i][2] = 0;
        } else { // zawracam
            A[i][0] = 2;
            A[i][1] = 0;
            A[i][2] -= T[i][2];
        }

    }

    // Ustalenie, która wskazówka jest, która, bo T[j][3] mówi, która jest na
    // pozycji j-tej
    for (long j = 1; j <= n; j++) {
        T[T[j][3]][4] = j;
    }

    // ustawianie drzewa na poczatkowe wartości (0,0) i do góry
    prepare_tree_to_hints(root);

    for (long j = 1; j <= n; j++) {
        temp_node.key = 0;
        temp_node.x = 0;
        temp_node.y = 0;
        inserts_on_position_and_updates_nodes(j, T[j][4], l, h, root, flunkey1, flunkey2);
        print_coordinates();
    }

}

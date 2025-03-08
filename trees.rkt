#lang racket
(require eopl)

(define-datatype tree tree?
  [leaf (key number?)]
  [node (key number?) (left-parent tree?) (right-parent tree?)])

(define node-1
  (leaf 1))
(define node-2
  (leaf 2))
(define root
  (node 3 node-1 node-2))


; (tree/map f tr): F X TR -> TR
; returns a new tree by applying each node to tr
; : tree is leaf? -> leaf(f(key))
; : tree is node? -> node(f(key), map(left), map (right))
(define tree/map
  (lambda (f tr)
    (cases tree tr
      (leaf (key)
            (leaf (f key)))
      (node (key left-parent right-parent)
            (node (f key) (tree/map f left-parent) (tree/map f right-parent))))))


; (tree/reduce f init tr): F X V X TR -> V
; reduces tree of values to a single value
; : tree is leaf? -> f(key, init)
; : tree is node? -> f(key, f(reduce(left), reduce(right)))
; : assuming that f is atleast a binary function (accepts min. 2 parameters)
(define tree/reduce
  (lambda (f init tr)
    (cases tree tr
      (leaf (key)
            (f key init))
      (node (key left-parent right-parent)
            (f key (f (tree/reduce f init left-parent) (tree/reduce f init right-parent)))))))

(define treeduce tree/reduce)
(define reduce tree/reduce)


; (tree/filter f tr): F X TR -> TR
; filter part of tree which satiesfies f
; : if a node's key does not satisfy f, both its subtrees are removed and its key set to 0
; : if a leaf's key does not satisfy f, its key is set to 0
(define tree/filter
  (lambda (f tr)
    (cases tree tr
      (leaf (key)
            (if (f key) (leaf key) (leaf 0)))
      (node (key left-parent right-parent)
            (if (f key) (node key (tree/filter f left-parent) (tree/filter f right-parent)) (leaf 0))))))


; (tree/path n tr): N X TR -> L
; returns list of lefts, rights showing path to n in tree tr, #f if not found
; : in case of leaf, key=n? -> () else #f
; : in case of node, key=n? -> (), in left subtree -> (left subtree), ...right, else #f
(define tree/path
  (lambda (n tr)
    (cases tree tr
      (leaf (key)
            (if (= key n) (list) #f))
      (node (key left-parent right-parent)
            (cond
              [(= key n) (list)]
              [(tree/path n left-parent) (cons `left (tree/path n left-parent))]
              [(tree/path n right-parent) (cons `right (tree/path n right-parent))]
              [else #f])))))

(define path tree/path)


; (list/reduce f init lst): F X V X L -> V
; reduces list of values to a single value
; : lst=null? -> init
; : else      -> f(lst[0], reduce(lst[1..end]))
(define list/reduce
  (lambda (f init lst)
    (if (null? lst)
        init
        (f (car lst) (list/reduce f init (cdr lst))))))

; (list/append n lst): N X L -> L
; appends a value to end of list
; : construct using each value of list to the value as list
(define list/append
  (lambda (n lst)
    (list/reduce cons (list n) lst)))

; (list/reverse lst): L -> L
; reverses the order of elements in a list
; : for each value from the end, append it to the list
(define list/reverse
  (lambda (lst)
    (list/reduce list/append (list) lst)))

(define reverse list/reverse)



; (pair/add1 p): P -> P
; increments first value of pair only
(define pair/add1
  (lambda (p)
    (cons (add1 (car p)) (cdr p))))

; (list/map f lst): F X L -> L
; applies a function to every element of list
(define list/map
  (lambda (f lst)
    (if (null? lst)
        (list)
        (cons (f (car lst)) (list/map f (cdr lst))))))

(define g
  (lambda (el lst)
    (cons el (list/map pair/add1 lst))))



(define atmost1?
  (lambda (lst)
    (or (null? lst) (null? (cdr lst)))))

; (swap lst): L -> L
; swaps the first two elements of list
(define swap
  (lambda (lst)
    (if (atmost1? lst)
        lst
        (cons (cadr lst) (cons (car lst) (cddr lst))))))

(define swap-by
  (lambda (lst f)
    (if (or (atmost1? lst) (f (car lst) (cadr lst)))
        lst
        (swap lst))))

(define bubble-once-by
  (lambda (lst f)
    (if (atmost1? lst)
        lst
        (let ([lst (swap-by lst f)])
          (cons (car lst) (bubble-once-by (cdr lst) f))))))

(define bubble-sort-by
  (lambda (lst f)
    (if (atmost1? lst)
        lst
        (bubble-once-by (cons (car lst) (bubble-sort-by (cdr lst) f)) f))))

(define bubble-sort
  (lambda (lst)
    (bubble-sort-by lst <=)))

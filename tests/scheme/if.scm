(write (if 12 1 2))
(newline)

(write (if "abc" 1 2))
(newline)

(write (if #f 1 2))
(newline)

(write (if (if 1 #t #f) 1 2))
(newline)

(write (if (if 1 #f #t) (if #t 1 2) (if #f 3 4)))
(newline)

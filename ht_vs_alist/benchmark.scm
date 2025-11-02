;;  -*-  indent-tabs-mode:nil; coding: utf-8 -*-
;;  Copyright (C) 2025
;;      "Mu Lei" known as "NalaGinrut" <mulei@gnu.org>
;;  This file is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License and GNU
;;  Lesser General Public License published by the Free Software
;;  Foundation, either version 3 of the License, or (at your option)
;;  any later version.

;;  This file is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License and GNU Lesser General Public License
;;  for more details.

;;  You should have received a copy of the GNU General Public License
;;  and GNU Lesser General Public License along with this program.
;;  If not, see <http://www.gnu.org/licenses/>.

;; benchmark.scm
;; Test assoc-list vs hashtable efficiency for 2000 elements
(import (ice-9 format))

(define n 2000)
(define keys (iota n))  ; 0..1999
(define vals (map (lambda (x) (string-append "value-" (number->string x))) keys))

;; -----------------------------
;; Time utility (ms)
;; -----------------------------
(define (now-ms)
  ;; convert Guile's internal time unit to milliseconds
  (/ (get-internal-real-time)
     (/ internal-time-units-per-second 1000)))

(define (benchmark name thunk)
  (let* ((start (now-ms))
         (result (thunk))
         (end (now-ms))
         (elapsed (- end start)))
    (format #t "~a: ~,3f ms~%" name elapsed)
    result))

;; -----------------------------
;; Data creation
;; -----------------------------
(define (make-alist)
  (map cons keys vals))

(define (make-ht)
  (let ((ht (make-hash-table)))
    (for-each (lambda (k v) (hash-set! ht k v)) keys vals)
    ht))

;; -----------------------------
;; Run benchmarks
;; -----------------------------
(display "Benchmarking assoc-list vs hashtable (2000 elements)\n\n")

(benchmark "Assoc-list creation"
  (lambda () (make-alist)))

(benchmark "Hashtable creation"
  (lambda () (make-ht)))

(let ((alist (make-alist))
      (ht (make-ht)))
  ;; 2000 random lookup keys
  (define lookup-keys (map (lambda (_) (random n)) (iota n)))

  (benchmark "Assoc-list lookup"
    (lambda ()
      (for-each (lambda (k) (assoc k alist)) lookup-keys)))

  (benchmark "Hashtable lookup"
             (lambda ()
               (for-each (lambda (k) (hash-ref ht k)) lookup-keys)))

  (benchmark "Assoc-list insertion"
             (lambda ()
               (let loop ((lst alist) (i 0))
                 (if (= i n)
                     lst
                     (loop (acons (+ n i) "new" lst) (+ i 1))))))

  (benchmark "Hashtable insertion"
             (lambda ()
               (let ((ht2 (make-hash-table)))
                 (for-each
                  (lambda (k v)
                    (hash-set! ht2 k v))
                  keys vals)
                 ht2))))

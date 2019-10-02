(in-package #:nepal)

(defclass event (audio)
  ((odds    :initarg :odds    :accessor event-odds)
   (pattern :initarg :pattern :accessor event-pattern)
   (volume  :initarg :volume  :accessor event-volume)
   (rate    :initarg :rate    :accessor event-rate)
   (loop-p  :initarg :loop-p  :accessor event-loop-p))
  (:default-initargs
   :odds 1f0
   :pattern nil
   :volume .5
   :rate 1f0
   :loop-p nil)
  (:documentation "first layer of metadata to control when and how play an audio"))

;; TODO: either pattern or buffer set, ENSURE
(defmethod initialize-instance :after ((obj event) &key pattern loop-p)
  "initialize pattern if not provided, and loop status"
  (check-type loop-p boolean)
  (al:source (audio-source obj) :looping loop-p)
  (unless pattern
    (setf (event-pattern obj) (cm:new cm:heap :of (audio-buffers obj)))))

(defun make-event (name paths &key (volume 0.1)
                                   (odds   1f0))
  (make-instance 'event :name name :paths paths :volume volume :odds odds))

(defmethod play ((obj event))
  "plays cm:next buffer element in pattern"
  (with-accessors ((pattern event-pattern)
                   (odds    event-odds)
                   (source  audio-source))
      obj
    (when (cm:odds odds)
      (let ((buffer (cm:next pattern)))
        (al:source source :buffer buffer)
        (al:source-play source)))))

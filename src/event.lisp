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
  (:documentation "layer of metadata to control when and how play an audio"))

;; TODO: either pattern or buffer set, ENSURE
(defmethod initialize-instance :after ((obj event) &key)
  "initialize pattern if not provided, and loop status"
  (with-slots (buffers fpattern pattern source loop-p) obj
    (check-type loop-p boolean)
    (al:source source :looping loop-p)
    (unless pattern
      (setf pattern (cm:new cm:heap :of buffers)))))

(defun make-event (name &rest paths &key (volume .1) &allow-other-keys)
  (remf paths :volume)
  (make-instance 'event :name name :paths paths :volume volume))

(defmethod play-audio ((obj event))
  "plays cm:next buffer element in pattern"
  (with-accessors ((pattern event-pattern) (source audio-source))
      obj
    (let ((buffer (cm:next pattern)))
      (al:source source :buffer buffer)
      (al:source-play source))))

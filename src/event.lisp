(in-package #:nepal)

(defclass event (audio)
  ((odds      :accessor event-odds      :initarg  :odds)
   (pattern   :accessor event-pattern   :initarg  :pattern)
   (volume    :accessor event-volume    :initarg  :volume)
   (rate      :accessor event-rate      :initarg  :rate)
   (loop-p    :accessor event-loop-p    :initarg  :loop-p)
   (gain      :accessor state-gain      :initform 1f0))
  (:default-initargs
   :odds 1f0
   :pattern nil
   :volume .5
   :rate 1f0
   :loop-p nil)
  (:documentation "first layer of metadata to control how to play an audio"))

(defgeneric update (obj dt))
(defmethod update :around (obj dt)
  "update only when source is playing"
  (let ((state (al:get-source (audio-source obj) :source-state)))
    (when (eq :PLAYING state)
      (call-next-method))))

(defmethod state-gain ((obj event))
  "query of the field is really a query on remote"
  (setf (slot-value obj 'gain)
        (al:get-source (audio-source obj) :gain)))
(defmethod (setf state-gain) :around (val (obj event))
  "update remote gain when updating slot"
  (al:source (audio-source obj) :gain val)
  (call-next-method))

;; TODO: either pattern or buffer set, ENSURE
(defmethod initialize-instance :after ((obj event) &key pattern loop-p)
  "initialize pattern if not provided, and loop status"
  (check-type loop-p boolean)
  (al:source (audio-source obj) :looping loop-p)
  (state-gain obj)
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

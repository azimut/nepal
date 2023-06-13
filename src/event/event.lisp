(in-package #:nepal)

;; TODO: offsets: sec sample byte
(defclass event (audio)
  ((odds          :accessor event-odds
                  :initarg  :odds
                  :documentation "chances the audio would play")
   (pattern       :accessor event-pattern       :initarg  :pattern)
   (volume        :accessor event-volume
                  :initarg  :volume
                  :documentation "OPENAL source parameter")
   (gain          :accessor state-gain
                  :initform 1f0)
   (rate          :accessor event-rate
                  :initarg  :rate
                  :documentation "OPENAL source parameter")
   (volume-offset :accessor event-volume-offset
                  :initarg  :volume-offset
                  :documentation "random volume width")
   (rate-offset   :accessor event-rate-offset
                  :initarg  :rate-offset
                  :documentation "random rate width")
   (loop-p        :accessor event-loop-p
                  :initarg  :loop-p
                  :documentation "OPENAL source parameter"))
  (:default-initargs
   :odds 1f0
   :pattern NIL
   :volume .5
   :rate 1f0
   :volume-offset 0f0
   :rate-offset 0f0
   :loop-p nil)
  (:documentation
   "first layer of metadata to control how to play an audio source"))

(defmethod initialize-instance
    :before ((obj event) &key odds loop-p rate volume-offset rate-offset)
  (check-type rate-offset single-float)
  (check-type volume-offset single-float)
  (check-type rate single-float)
  (check-type odds (single-float 0f0 1f0))
  (check-type loop-p boolean))

;; TODO: either pattern or buffer set, ENSURE
(defmethod initialize-instance
    :after ((obj event) &key pattern loop-p)
  (al:source (audio-source obj) :looping loop-p)
  (unless pattern
    (setf (event-pattern obj)
          (cm:new cm:heap :of (audio-buffers obj)))))

(defgeneric update (obj dt))
(defmethod update :around ((obj event) dt)
  (let ((state (al:get-source (audio-source obj) :source-state)))
    (when (eq :PLAYING state)
      (call-next-method))))

(defmethod (setf event-odds) :before (new-value (obj event))
  (check-type new-value (single-float 0f0 1f0)))
(defmethod (setf event-loop-p) :before (new-value (obj event))
  (check-type new-value boolean))

(defmethod (setf event-loop-p) :after (new-value (obj event))
  (al:source (audio-source obj) :looping new-value))

(defmethod state-gain ((obj event))
  (setf (slot-value obj 'gain)
        (al:get-source (audio-source obj) :gain)))

(defmethod (setf state-gain) :around (val (obj event))
  (al:source (audio-source obj) :gain val)
  (call-next-method))

(defun make-event (name paths &key (volume 0.1) (odds 1f0) (pos (v! 0 0 0)) (volume-offset 0f0) (rate-offset 0f0) (rate 1f0))
  (make-instance 'event :name name :paths paths :rate rate :volume volume :odds odds :pos pos
                        :rate-offset rate-offset :volume-offset volume-offset))

(declaim (inline random-offset))
(defun random-offset (value offset)
  (if (zerop offset)
      value
      (+ value (- (random offset) (/ offset 2f0)))))

(defmethod play ((obj event))
  "plays cm:next buffer element in pattern"
  (with-slots (pattern odds rate volume source rate-offset volume-offset)
      obj
    (when (cm:odds odds)
      (let ((buffer (cm:next pattern))
            (new-volume (random-offset volume volume-offset))
            (new-rate   (random-offset rate   rate-offset)))
        (al:source source :buffer buffer)
        (al:source source :gain   new-volume)
        (al:source source :pitch  new-rate)
        (al:source-play source)))))

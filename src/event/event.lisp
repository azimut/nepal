(in-package #:nepal)

;; TODO: offsets: sec sample byte
(defclass event (audio)
  ((odds          :accessor event-odds
                  :initarg  :odds
                  :documentation "chances the audio would play")
   (pattern       :accessor event-pattern       :initarg  :pattern)
   (gain-offset   :accessor event-gain-offset
                  :initarg  :gain-offset
                  :documentation "random volume width")
   (pitch-offset  :accessor event-pitch-offset
                  :initarg  :pitch-offset
                  :documentation "random pitch width")
   (loop-p        :accessor event-loop-p
                  :initarg  :loop-p
                  :documentation "OPENAL source parameter")
   (step-size     :accessor event-step-size
                  :initarg  :step-size
                  :documentation "frequency in seconds, each sound is played again")
   (stepper       :reader   event-stepper
                  :initform nil
                  :documentation "the stepper"))
  (:default-initargs
   :odds 1f0
   :pattern NIL
   :gain-offset 0f0
   :pitch-offset 0f0
   :loop-p nil
   :step-size 0f0)
  (:documentation
   "first layer of metadata to control how to play an audio source"))

(defmethod initialize-instance
    :before ((obj event) &key odds loop-p gain-offset pitch-offset)
  (check-type pitch-offset single-float)
  (check-type gain-offset single-float)
  (check-type odds (single-float 0f0 1f0))
  (check-type loop-p boolean))

;; TODO: either pattern or buffer set, ENSURE
(defmethod initialize-instance
    :after ((obj event) &key pattern loop-p step-size)
  (al:source (audio-source obj) :looping loop-p)
  (when (plusp step-size)
    (setf (slot-value obj 'stepper)
          (make-stepper (seconds step-size) (seconds step-size))))
  (unless pattern
    (setf (event-pattern obj)
          (cm:new cm:heap :of (audio-buffers obj)))))

(defgeneric update (obj dt))
(defmethod update :around ((obj event) dt)
  (let ((state (al:get-source (audio-source obj) :source-state)))
    (when (eq :PLAYING state)
      (call-next-method))))

(defmethod (setf event-step-size) :before (new-value (obj event))
  (assert (plusp new-value)))
(defmethod (setf event-odds) :before (new-value (obj event))
  (check-type new-value (single-float 0f0 1f0)))
(defmethod (setf event-loop-p) :before (new-value (obj event))
  (check-type new-value boolean))

(defmethod (setf event-step-size) :after (new-value (obj event))
  (setf (slot-value obj 'stepper)
        (make-stepper (seconds new-value) (seconds new-value))))
(defmethod (setf event-loop-p) :after (new-value (obj event))
  (al:source (audio-source obj) :looping new-value))

(declaim (inline random-offset))
(defun random-offset (value offset)
  (if (zerop offset)
      value
      (+ value (- (random offset) (/ offset 2f0)))))

(defmethod play :around ((obj event))
  (with-slots (stepper) obj
    (when (or (not stepper) (funcall stepper))
      (call-next-method))))

(defmethod play ((obj event))
  (with-slots (pattern odds pitch gain source pitch-offset gain-offset)
      obj
    (when (cm:odds odds)
      (let ((buffer     (cm:next pattern));; !
            (new-volume (random-offset gain gain-offset))
            (new-pitch  (random-offset pitch pitch-offset)))
        (al:source source :buffer buffer)
        (al:source source :pitch  new-pitch)
        (al:source source :gain   new-volume)
        (al:source-play source)))))

(defun make-event (&rest args)
  (apply #'make-instance 'event args))

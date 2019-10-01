(in-package #:nepal)

(defclass sfx (event)
  ((pos-offset    :initarg :pos-offset    :accessor sfx-pos-offset)
   (volume-offset :initarg :volume-offset :accessor sfx-volume-offset)
   (rate-offset   :initarg :rate-offset   :accessor sfx-rate-offset)
   (stepper       :initarg :stepper       :accessor sfx-stepper)
   (step-size     :initarg :step-size     :accessor sfx-step-size))
  (:default-initargs
   :pos-offset (v! 0 0 0)
   :volume-offset 0f0
   :rate-offset 0f0
   :stepper t
   :step-size 0f0)
  (:documentation "special type of event for sfx needs"))

(defmethod initialize-instance :after ((obj sfx) &key)
  (with-slots (stepper step-size) obj
    (when (not (zerop step-size))
      (setf stepper (make-stepper (seconds step-size) (seconds step-size))))))

;; update
;; play-audio
;; stop-audio
;; make-sfxx

(in-package #:nepal)

;; TODO: might be cram the globals here too?
(defclass listener ()
  ((prev-pos :reader   listener-prev-pos
             :initform (v! 0 0 0)
             :documentation "previous position, to calculate the velocity")
   (prev-ts  :accessor listener-prev-ts
             :initform 0f0
             :documentation "previous timestamp")
   (rot      :accessor rot
             :initarg :rot)
   (velocity :accessor velocity
             :initform (v! 0 0 0)
             :documentation "OpenAL listener parameter")
   (gain     :accessor gain
             :initarg :gain
             :documentation "OpenAL listener parameter")
   (pos      :accessor pos
             :initarg :pos
             :documentation "OpenAL listener parameter"))
  (:default-initargs
   :gain 1f0
   :pos (v! 0 0 0)
   :rot (q:identity))
  (:documentation "interface? to openal listener...can only be 1.
    By updating the position and rotation of this class, the position,
    velocity and orientation would be calculated and update on OpenAL."))

(defmethod initialize-instance :before ((obj listener) &key pos)
  (check-type pos rtg-math.types:vec3))
(defmethod initialize-instance :after ((obj listener) &key pos gain)
  (init-audio)
  (al:listener :velocity (velocity obj))
  (al:listener :position pos)
  (al:listener :gain gain))

(defmethod (setf velocity) :before (value (obj listener))
  (check-type value rtg-math.types:vec3))
(defmethod (setf velocity) :after (value (obj listener))
  (al:listener :velocity value))

(defmethod (setf gain) :before (value (obj listener))
  (check-type value (single-float 0f0 16f0)))
(defmethod (setf gain) :after (value (obj listener))
  (al:listener :gain value))

;; https://gamedev.stackexchange.com/questions/112937/2d-physics-storing-previous-position-vs-storing-velocity
(defmethod (setf pos) :before (new-pos (obj listener))
  (check-type new-pos rtg-math.types:vec3)
  (with-slots (prev-pos pos prev-ts) obj
    (setf prev-pos pos)
    (let* ((ts (* .1f0 (get-internal-real-time)))
           (dt (- ts prev-ts)))
      (setf (velocity obj) (v3:/s (v3:- new-pos prev-pos) dt))
      (setf prev-ts        ts))))
(defmethod (setf pos) :after (new-pos (obj listener))
  (al:listener :position new-pos))

(defmethod (setf rot) :before (value (obj listener))
  (check-type value rtg-math.types:quaternion))
(defmethod (setf rot) :after (value (obj listener))
  (al:listener :orientation (concatenate 'vector (q:to-direction (rot obj)) (v! 0 1 0))))

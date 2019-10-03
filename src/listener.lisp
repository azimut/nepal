(in-package #:nepal)

;; TODO: might be cram the globals here too?
(defclass listener ()
  ((prev-pos :reader   listener-prev-pos :initarg :prev-pos)
   (prev-ts  :accessor listener-prev-ts  :initarg :prev-ts)
   (pos      :accessor pos               :initarg :pos)
   (rot      :accessor rot               :initarg :rot)
   (velocity :accessor velocity          :initarg :velocity))
  (:default-initargs
   :prev-pos (v! 0 0 0)
   :pos (v! 0 0 0)
   :rot (q:identity)
   :prev-ts (* .1f0 (get-internal-real-time))
   :velocity (v! 0 0 0))
  (:documentation "interface? to openal listener...can only be 1"))

(defmethod initialize-instance :after ((obj listener) &key pos velocity)
  "reset OpenAL state on new instance"
  (check-type pos rtg-math.types:vec3)
  (al:listener :position pos)
  (al:listener :velocity velocity))

(defmethod (setf velocity) :before (value (obj listener))
  (check-type value rtg-math.types:vec3))
(defmethod (setf velocity) :after (value (obj listener))
  (al:listener :velocity value))

;; https://gamedev.stackexchange.com/questions/112937/2d-physics-storing-previous-position-vs-storing-velocity
(defmethod (setf pos) :before (value (obj listener))
  (check-type value rtg-math.types:vec3)
  (with-slots (prev-pos pos prev-ts) obj
    (let* ((ts (* .1f0 (get-internal-real-time)))
           (dt (- ts prev-ts)))
      (setf prev-pos       pos)
      (setf (velocity obj) (v3:/s (v3:- value prev-pos) dt))
      (setf prev-ts        ts))))
(defmethod (setf pos) :after (value (obj listener))
  (al:listener :position value))

(defmethod (setf rot) :before (value (obj listener))
  (check-type value rtg-math.types:quaternion))
(defmethod (setf rot) :after (value (obj listener))
  (al:listener :orientation (concatenate 'vector (q:to-direction (rot obj)) (v! 0 1 0))))

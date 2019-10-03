(in-package #:nepal)

;; mmm...I am not so sure about this...

(defclass positional (event)
  ((pos        :initarg :pos        :accessor state-pos)      ; update
   (prev-pos   :initarg :prev-pos   :accessor state-prev-pos) ; ?
   (prev-ts    :initarg :prev-ts    :accessor state-prev-ts)
   (velocity   :initarg :velocity   :accessor state-velocity) ; update
   (direction  :initarg :direction  :accessor state-direction) ; init/update
   (cone-inner :initarg :cone-inner :accessor state-cone-inner) ; init
   (cone-outer :initarg :cone-outer :accessor state-cone-outer) ; init
   (rolloff    :initarg :rolloff    :accessor state-rolloff)    ; init
   (outer-gain :initarg :outer-gain :accessor state-outer-gain) ; init
   ;;(max-distance :accessor state-outer-gain :initform nil)
   ;;min-gain
   ;;max-gain
   )
  (:default-initargs
   :pos (v! 0 0 0)
   :prev-pos (v! 0 0 0)
   :prev-ts (* .1f0 (get-internal-real-time))
   :velocity (v! 0 0 0)
   :direction (v! 0 0 0)
   :cone-inner 360f0
   :cone-outer 360f0
   :rolloff 1f0
   :outer-gain 0f0)
  (:documentation "second layer of metadata to control where to play the audio"))

(defmethod initialize-instance :after ((obj positional) &key pos)
  (al:source (audio-source obj) :position pos))

(defmethod state-pos ((obj positional))
  (setf (slot-value obj 'pos)
        (al:get-source (audio-source obj) :position)))
(defmethod state-direction ((obj positional))
  (setf (slot-value obj 'direction)
        (al:get-source (audio-source obj) :direction)))
(defmethod state-velocity ((obj positional))
  (setf (slot-value obj 'velocity)
        (al:get-source (audio-source obj) :velocity)))
(defmethod state-cone-inner ((obj positional))
  (setf (slot-value obj 'cone-inner)
        (al:get-source (audio-source obj) :cone-inner-angle)))
(defmethod state-cone-outer ((obj positional))
  (setf (slot-value obj 'cone-outer)
        (al:get-source (audio-source obj) :cone-outer-angle)))
(defmethod state-rolloff ((obj positional))
  (setf (slot-value obj 'rolloff)
        (al:get-source (audio-source obj) :rolloff-angle)))
(defmethod state-outer-gain ((obj positional))
  (setf (slot-value obj 'outer-gain)
        (al:get-source (audio-source obj) :cone-outer-gain)))

(defmethod (setf state-pos) :before (val (obj positional))
  "when position is updated keep track of the old one and calculate the velocity"
  (check-type val rtg-math.types:vec3)
  (let* ((direction (v3:- (state-prev-pos obj) val))
         (ts (* .1f0 (get-internal-real-time)))
         (dt (- ts (state-prev-ts obj))))
    (setf (state-prev-pos obj) (copy-seq (slot-value obj 'pos)))
    (setf (state-velocity obj) (v3:/s direction dt))
    (setf (state-prev-ts  obj) ts)))
(defmethod (setf state-pos) :after (val (obj positional))
  "after updating locally update remote"
  (al:source (audio-source obj) :position val))

(defmethod (setf state-direction) :before (val (obj positional))
  (check-type val rtg-math.types:vec3))
(defmethod (setf state-direction) :after (val (obj positional))
  (al:source (audio-source obj) :direction val))
(defmethod (setf state-velocity) :before (val (obj positional))
  (check-type val rtg-math.types:vec3))
(defmethod (setf state-velocity) :after (val (obj positional))
  (al:source (audio-source obj) :velocity val))

(defmethod (setf state-cone-inner) :before (val (obj positional))
  (check-type val (single-float 0f0 360f0)))
(defmethod (setf state-cone-inner) :after (val (obj positional))
  (al:source (audio-source obj) :cone-inner-angle val))
(defmethod (setf state-cone-outer) :before (val (obj positional))
  (check-type val (single-float 0f0 360f0)))
(defmethod (setf state-cone-outer) :after (val (obj positional))
  (al:source (audio-source obj) :cone-outer-angle val))

(defmethod (setf state-rolloff) :before (val (obj positional))
  (check-type val single-float))
(defmethod (setf state-rolloff) :after (val (obj positional))
  (al:source (audio-source obj) :rolloff-factor val))

(defmethod (setf state-outer-gain) :before (val (obj positional))
  (check-type val (single-float 0f0 1f0)))
(defmethod (setf state-outer-gain) :after (val (obj positional))
  (al:source (audio-source obj) :cone-outer-gain val))

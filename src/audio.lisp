(in-package #:nepal)

(defclass audio ()
  ((name      :initarg :name      :reader   audio-name
              :documentation "used to to cache/lookup the audio source")
   (buffers   :initarg :buffers   :reader   audio-buffers :initform ()
              :documentation "ALUT audio buffers")
   (paths     :initarg :paths     :reader   audio-paths
              :documentation "ALUT audio buffers original file paths")
   (source    :initarg :source    :reader   audio-source
              :documentation "OpenAL source")
   (gain      :initarg :gain      :accessor audio-gain
              :documentation "OpenAL source parameter")
   (pitch     :initarg :pitch     :accessor audio-pitch
              :documentation "OPENAL source parameter")
   (relativep :initarg :relativep :reader   audio-relativep
              :documentation "OpenAL source parameter, if T audio is in local space")
   (overlap-p :initarg :overlap-p :accessor audio-overlap-p
              :documentation "whether overlap sounds OR wait until they finish")
   (pos       :initarg :pos       :accessor pos
              :documentation "OpenAL source parameter, audio position"))
  (:default-initargs
   :name (gensym)
   :paths (list)
   :gain 1f0
   :pitch 1f0
   :relativep T
   :overlap-p NIL
   :pos (v! 0 0 0))
  (:documentation "bare minimun data to play a file with OpenAL"))

(defmethod initialize-instance
    :before ((obj audio) &key name paths relativep pos overlap-p gain pitch)
  (check-type pitch single-float)
  (check-type gain single-float)
  (check-type pos rtg-math.types:vec3)
  (check-type overlap-p boolean)
  (check-type relativep boolean)
  (check-type name keyword)
  (check-type paths list))

(defmethod initialize-instance
    :after ((obj audio) &key name paths relativep pos gain pitch)
  (with-slots (buffers source) obj
    (setf buffers (mapcar (lambda (_) (load-abuffer (truename _))) paths))
    (setf source (init-source name))
    (al:source source :gain gain)
    (al:source source :pitch pitch)
    (al:source source :position pos)
    (al:source source :source-relative relativep)))

(defmethod (setf audio-gain) :before (new-value (obj audio))
  (check-type new-value single-float))
(defmethod (setf audio-pitch) :before (new-value (obj audio))
  (check-type new-value single-float))
(defmethod (setf audio-relativep) :before (new-value (obj audio))
  (check-type new-value boolean))
(defmethod (setf audio-overlap-p) :before (new-value (obj audio))
  (check-type new-value boolean))

(defmethod (setf pos) :after (val (obj audio))
  (al:source (audio-source obj) :position val))
(defmethod (setf audio-gain) :after (val (obj audio))
  (al:source (audio-source obj) :gain val))
(defmethod (setf audio-pitch) :after (val (obj audio))
  (al:source (audio-source obj) :pitch val))

(defmethod audio-gain ((obj audio))
  (setf (slot-value obj 'gain) (al:get-source (audio-source obj) :gain)))
(defmethod audio-pitch ((obj audio))
  (setf (slot-value obj 'pitch) (al:get-source (audio-source obj) :pitch)))
(defmethod pos ((obj audio))
  (setf (slot-value obj 'pos) (al:get-source (audio-source obj) :position)))

(defmethod play :around ((obj audio))
  (with-slots (source overlap-p) obj
    (let ((playing-p (eq :PLAYING (al:get-source source :source-state))))
      (when (and overlap-p playing-p)
        (stop obj))
      (when (and overlap-p (not playing-p))
        (call-next-method)))))

(defmethod play ((obj audio))
  (with-slots (buffers source) obj
    (let ((buffer (alexandria:random-elt buffers)))
      (al:source source :buffer buffer)
      (al:source-play source))))

(defmethod stop ((obj audio))
  (al:source-stop (audio-source obj)))

(defun make-audio (&rest args)
  (apply #'make-instance 'audio args))

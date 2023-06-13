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
   (relativep :initarg :relativep :reader   audio-relativep
              :documentation "OpenAL source parameter, if T audio is in local space")
   (pos       :initarg :pos       :accessor pos
              :documentation "OpenAL source parameter, audio position"))
  (:default-initargs
   :name (gensym)
   :paths (list)
   :relativep T
   :pos (v! 0 0 0))
  (:documentation "bare minimun data to play a file with OpenAL"))

(defmethod initialize-instance
    :before ((obj audio) &key name paths relativep pos)
  (check-type pos rtg-math.types:vec3)
  (check-type relativep boolean)
  (check-type name keyword)
  (check-type paths list))

(defmethod initialize-instance
    :after ((obj audio) &key name paths relativep pos)
  (with-slots (buffers source) obj
    (setf buffers (mapcar (lambda (_) (load-abuffer (truename _))) paths))
    (setf source (init-source name))
    (al:source source :position pos)
    (al:source source :source-relative relativep)))

(defmethod pos ((obj audio))
  (setf (slot-value obj 'pos) (al:get-source (audio-source obj) :position)))
(defmethod (setf pos) :after (val (obj audio))
  (al:source (audio-source obj) :position val))

(defun make-audio (name paths &key (pos (v! 0 0 0)))
  (make-instance 'audio :name name :paths paths :pos pos))

(defmethod play :around ((obj audio))
  (let ((state (al:get-source (audio-source obj) :source-state)))
    (when (not (eq :PLAYING state))
      (call-next-method))))

(defmethod play ((obj audio))
  (with-slots (buffers source) obj
    (let ((buffer (alexandria:random-elt buffers)))
      (al:source source :buffer buffer)
      (al:source-play source))))

(defmethod stop ((obj audio))
  (al:source-stop (audio-source obj)))

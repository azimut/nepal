(in-package #:nepal)

;; TODO: fade-time, that is give a time in seconds to fade.
;; with current code, you need to try to ensure a fixed fps

(defclass music (event)
  ((fading-out-p :initarg :fading-out-p :accessor music-fading-out-p)
   (fading-in-p  :initarg :fading-in-p  :accessor music-fading-in-p)
   (fade-by      :initarg :fade-by      :accessor music-fade-by))
  (:default-initargs
   :fading-out-p nil
   :fading-in-p t
   :fade-by .01
   :loop-p t)
  (:documentation "special type of event for music"))

(defun make-music (name paths &key (fade-by 0.01)
                                   (volume  0.5))
  "music layer, can have variations in different files..."
  (make-instance 'music :name name :paths paths :volume volume :fade-by fade-by))

(defmethod play ((obj music))
  "plays cm:next buffer element in pattern"
  (with-accessors ((pattern event-pattern)
                   (source  audio-source))
      obj
    (let ((buffer (cm:next pattern)))
      (al:source source :buffer buffer)
      (al:source source :gain 0f0); let fade-in kick in on (update)
      (al:source-play source))))

(defmethod stop ((obj music))
  "do not stop the audio directly, delegate fade out to (update)"
  (with-slots (fading-out-p) obj
    (unless fading-out-p
      (setf fading-out-p t))))

;; TODO: move if outside...
(defmethod update ((obj music) dt)
  "called by emitter, fade out/in when needed"
  (with-slots (fading-out-p fading-in-p fade-by source volume) obj
    (let ((current-gain (al:get-source source :gain)))
      (when fading-out-p
        (let ((new-gain (max 0f0 (- current-gain (/ fade-by dt)))))
          (if (= current-gain 0)
              (setf fading-out-p nil
                    fading-in-p t);?
              (al:source source :gain new-gain))))
      (when fading-in-p
        (let ((new-gain (min volume (+ current-gain fade-by))))
          (if (>= current-gain volume)
              (setf fading-in-p  nil
                    fading-out-p nil)
              (al:source source :gain new-gain)))))))

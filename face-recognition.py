import cv2
import numpy
import libardrone
import sys

#drone = libardrone.ARDrone()
cap = cv2.VideoCapture('tcp://192.168.1.1:5555')

cascPath = sys.argv[1]
faceCascade = cv2.CascadeClassifier(cascPath)

while(True):
    if not cap:
        #time.sleep(0.1)   # or something to save just a touch of CPU spin time, optional
        continue
    ret, frame = cap.read()
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = faceCascade.detectMultiScale(
                                         gray,
                                         scaleFactor=1.1,
                                         minNeighbors=5,
                                         minSize=(30, 30),
                                         flags=cv2.CASCADE_SCALE_IMAGE
                                         )
        
    # Draw a rectangle around the faces
    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x+w, y+h), (0, 255, 0), 2)
                                         
    # Display the resulting frame
    cv2.imshow('Video', frame)
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
        
cap.release()
cv2.destroyAllWindows()
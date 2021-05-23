from time import sleep

import rospy
from geometry_msgs.msg import Quaternion
from geometry_msgs.msg import Vector3
from mavros_msgs.msg import Thrust
from mavros_msgs.msg import AttitudeTarget

node = rospy.init_node("thrust_test")

rate = rospy.Rate(20)  # Hz
pub = rospy.Publisher('/mavros/setpoint_raw/attitude', AttitudeTarget, queue_size=1)

print("looping!")
while True:
    msg = AttitudeTarget()
    msg.orientation = Quaternion(x=0.0, y=0.0, z=0.0, w=1.0)
    msg.body_rate = Vector3(x=0.0, y=0.0, z=0.0)
    msg.thrust = -0.001
    pub.publish(msg)

    rate.sleep()
    print("Sending thrust [%f]!" % msg.thrust)

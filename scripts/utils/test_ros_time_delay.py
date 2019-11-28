#!/usr/bin/env python
import rospy
from geometry_msgs.msg import PoseStamped
from geometry_msgs.msg import PoseWithCovarianceStamped

TARGET_TOPIC="/vrpn_client_node/ucl_0/pose"

def pose_stamped_cb(data):
    msg_stamp = data.header.stamp
    time_now = rospy.Time.now()
    print("Time delay: " + str((time_now - msg_stamp).to_sec()) + "s")

if __name__ == "__main__":
    rospy.init_node("TimeDelayChecker", anonymous=True)
    rospy.Subscriber(TARGET_TOPIC, PoseWithCovarianceStamped, pose_stamped_cb)
    rospy.spin()

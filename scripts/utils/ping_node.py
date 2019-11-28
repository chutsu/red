#!/usr/bin/env python
import rospy
from std_msgs.msg import Header

def ping():
    pub = rospy.Publisher('/ping', Header, queue_size=10)
    rospy.init_node('ping_source', anonymous=True)
    rate = rospy.Rate(10) # 10hz

    seq = 0
    while not rospy.is_shutdown():
 	msg = Header()
        msg.seq = seq
        msg.stamp = rospy.Time.now()
        msg.frame_id = "n/a"
	seq += 1

        pub.publish(msg)
        rate.sleep()

if __name__ == '__main__':
        ping()

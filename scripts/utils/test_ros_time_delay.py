#!/usr/bin/env python
import numpy as np
import rospy
from std_msgs.msg import Header
from geometry_msgs.msg import PoseStamped
from geometry_msgs.msg import PoseWithCovarianceStamped

TARGET_TOPIC="/ping"
timestamps = np.array([])
time_delays = np.array([])

def header_cb(msg):
    msg_ts = msg.stamp
    time_now = rospy.Time.now()
    time_delay_now = (time_now - msg_ts).to_sec()
    print("Time delay: " + str(time_delay_now) + "s")

    global timestamps
    global time_delays
    timestamps = np.append(timestamps, time_now.to_nsec())
    time_delays = np.append(time_delays, time_delay_now)
    if time_delays.size > 1000:
    data = zip(timestamps, time_delays)
    save_path = "ros_time_delays.csv"
    header = "timestamp[ns],time_delay[s]"
    np.savetxt(save_path, data, delimiter=",",
               header=header, fmt="%ld,%f")
    rospy.signal_shutdown(-1)

if __name__ == "__main__":
    rospy.init_node("TimeDelayChecker", anonymous=True)
    rospy.Subscriber(TARGET_TOPIC, Header, header_cb)
    rospy.spin()

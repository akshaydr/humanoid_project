#!/usr/bin/env python
import os
import rospy
from time import sleep
from std_msgs.msg import Float64
from motor_param import *


if os.name == 'nt':
    import msvcrt
    def getch():
        return msvcrt.getch().decode()
else:
    import sys, tty, termios
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    def getch():
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch

from dynamixel_sdk import *                    # Uses Dynamixel SDK library

# Control table address
ADDR_PRO_TORQUE_ENABLE      = 64               # Control table address is different in Dynamixel model
ADDR_PRO_GOAL_POSITION      = 116
ADDR_PRO_PRESENT_POSITION   = 132

# Data Byte Length
LEN_PRO_GOAL_POSITION       = 4
LEN_PRO_PRESENT_POSITION    = 4

# Protocol version
PROTOCOL_VERSION            = 2.0               # See which protocol version is used in the Dynamixel

# Default setting
DXL2_ID                     = 2                # Dynamixel#1 ID : 1
DXL3_ID                     = 3                 # Dynamixel#1 ID : 1
DXL4_ID                     = 4                  # Dynamixel#1 ID : 1
DXL5_ID                     = 5                  # Dynamixel#1 ID : 1
DXL6_ID                     = 6                  # Dynamixel#1 ID : 1

DXL8_ID                     = 8                # Dynamixel#1 ID : 1
DXL9_ID                     = 9                 # Dynamixel#1 ID : 1
DXL10_ID                    = 10                  # Dynamixel#1 ID : 1
DXL11_ID                    = 11                 # Dynamixel#1 ID : 1
DXL12_ID                    = 12                 # Dynamixel#1 ID : 1

DXL15_ID                     = 15                             # Dynamixel ID: 1
DXL16_ID                     = 16
DXL17_ID                     = 17                            # Dynamixel ID: 1
DXL18_ID                     = 18
DXL19_ID                     = 19                            # Dynamixel ID: 1
DXL20_ID                     = 20
DXL21_ID                     = 21                            # Dynamixel ID: 1
DXL22_ID                     = 22
DXL23_ID                     = 23
DXL24_ID                     = 24

DXL25_ID                     = 25


BAUDRATE                    = 1000000             # Dynamixel default baudrate : 57600
DEVICENAME                  = '/dev/ttyUSB0'    # Check which port is being used on your controller
                                                # ex) Windows: "COM1"   Linux: "/dev/ttyUSB0" Mac: "/dev/tty.usbserial-*"

TORQUE_ENABLE               = 1                 # Value for enabling the torque
TORQUE_DISABLE              = 0                 # Value for disabling the torque
DXL_MINIMUM_POSITION_VALUE  = 100          # Dynamixel will rotate between this value
DXL_MAXIMUM_POSITION_VALUE  = 4000            # and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
DXL_MOVING_STATUS_THRESHOLD = 20                # Dynamixel moving status threshold

index = 0
dxl_goal_position = [DXL_MINIMUM_POSITION_VALUE, DXL_MAXIMUM_POSITION_VALUE]         # Goal position


portHandler = PortHandler(DEVICENAME)
packetHandler = PacketHandler(PROTOCOL_VERSION)
groupSyncWrite = GroupSyncWrite(portHandler, packetHandler, ADDR_PRO_GOAL_POSITION, LEN_PRO_GOAL_POSITION)
groupSyncRead = GroupSyncRead(portHandler, packetHandler, ADDR_PRO_PRESENT_POSITION, LEN_PRO_PRESENT_POSITION)

# abduction_right =   2036
# hip_right =         2141
# knee_right =        2527
# ankle_right =       1651
# ankle_twist_right = 2036
#
# abduction_left =    2036
# hip_left =          2431
# knee_left =         2669
# ankle_left =        1798
# ankle_twist_left =  2036

# rotation_right =    2036
# abduction_right =   2036
# hip_right =         2407
# knee_right =        2636
# ankle_right =       1728
# ankle_twist_right = 2036
#
# rotation_left =     2036
# abduction_left =    2036
# hip_left =          2135
# knee_left =         2395
# ankle_left =        1728
# ankle_twist_left =  2036

rotation_right =    2036
abduction_right =   2036
hip_right =         2036
knee_right =        2036
ankle_right =       2036
ankle_twist_right = 2036

rotation_left =     2036
abduction_left =    2036
hip_left =          2036
knee_left =         2036
ankle_left =        2036
ankle_twist_left =  2036

# rotation_right =    2036
# abduction_right =   1921
# hip_right =         2224
# knee_right =        2655
# ankle_right =       1605
# ankle_twist_right = 2150
#
# rotation_left =     2036
# abduction_left =    1921
# hip_left =          2412
# knee_left =         2721
# ankle_left =        1727
# ankle_twist_left =  2150

right_1 = 2036
right_2 = 2036
right_3 = 2036
right_4 = 2036
right_5 = 2036

left_1 = 2036
left_2 = 2036
left_3 = 2036
left_4 = 2036
left_5 = 2036

head = 2036

# Open port
if portHandler.openPort():
    print("Succeeded to open the port")
else:
    print("Failed to open the port")
    print("Press any key to terminate...")
    getch()
    quit()

# Set port baudrate
if portHandler.setBaudRate(BAUDRATE):
    print("Succeeded to change the baudrate")
else:
    print("Failed to change the baudrate")
    print("Press any key to terminate...")
    getch()
    quit()


def initialize_motor(ID):
    # Enable Dynamixel#1 Torque
    dxl_comm_result, dxl_error = packetHandler.write1ByteTxRx(portHandler, ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE)
    if dxl_comm_result != COMM_SUCCESS:
        print("%s" % packetHandler.getTxRxResult(dxl_comm_result))
    elif dxl_error != 0:
        print("%s" % packetHandler.getRxPacketError(dxl_error))
    else:
        print("Dynamixel#%d has been successfully connected" % ID)

    # Add parameter storage for Dynamixel#1 present position value
    dxl_addparam_result = groupSyncRead.addParam(ID)
    if dxl_addparam_result != True:
        print("[ID:%03d] groupSyncRead addparam failed" % ID)
        quit()

def run_motor(ID, data):
    # Allocate goal position value into byte array
    param_goal_position = [DXL_LOBYTE(DXL_LOWORD(int(data))), DXL_HIBYTE(DXL_LOWORD(int(data))), DXL_LOBYTE(DXL_HIWORD(int(data))), DXL_HIBYTE(DXL_HIWORD(int(data)))]

    # Add Dynamixel#1 goal position value to the Syncwrite parameter storage
    dxl_addparam_result = groupSyncWrite.addParam(ID, param_goal_position)
    if dxl_addparam_result != True:
        print("[ID:%03d] groupSyncWrite addparam failed" % ID)
        quit()

    # Syncwrite goal position
    dxl_comm_result = groupSyncWrite.txPacket()
    if dxl_comm_result != COMM_SUCCESS:
        print("%s" % packetHandler.getTxRxResult(dxl_comm_result))

    groupSyncWrite.clearParam()
    # Clear syncwrite parameter storage

def torque_diable(ID):
    # Disable Dynamixel Torque
    dxl_comm_result, dxl_error = packetHandler.write1ByteTxRx(portHandler, ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_DISABLE)
    if dxl_comm_result != COMM_SUCCESS:
        print("%s" % packetHandler.getTxRxResult(dxl_comm_result))
    elif dxl_error != 0:
        print("%s" % packetHandler.getRxPacketError(dxl_error))

# Right Leg
def rotation_r_callback(msg):
    global rotation_right
    rotation_right = msg.data
def abduction_r_callback(msg):
    global abduction_right
    abduction_right = msg.data
def knee_r_callback(msg):
    global knee_right
    knee_right = msg.data
def hip_r_callback(msg):
    global hip_right
    hip_right = msg.data
def ankle_r_callback(msg):
    global ankle_right
    ankle_right = msg.data
def ankle_twist_r_callback(msg):
    global ankle_twist_right
    ankle_twist_right = msg.data

# Left Leg
def rotation_l_callback(msg):
    global rotation_left
    rotation_left = msg.data
def abduction_l_callback(msg):
    global abduction_left
    abduction_left = msg.data
def hip_l_callback(msg):
    global hip_left
    hip_left = msg.data
def knee_l_callback(msg):
    global knee_left
    knee_left = msg.data
def ankle_l_callback(msg):
    global ankle_left
    ankle_left = msg.data
def ankle_twist_l_callback(msg):
    global ankle_twist_left
    ankle_twist_left = msg.data

# Right Hand
def right_1_callback(msg):
    global right_1
    right_1 = msg.data
def right_2_callback(msg):
    global right_2
    right_2 = msg.data
def right_3_callback(msg):
    global right_3
    right_3 = msg.data
def right_4_callback(msg):
    global right_4
    right_4 = msg.data
def right_5_callback(msg):
    global right_5
    right_5 = msg.data

# Left Hand
def left_1_callback(msg):
    global left_1
    left_1 = msg.data
def left_2_callback(msg):
    global left_2
    left_2 = msg.data
def left_3_callback(msg):
    global left_3
    left_3 = msg.data
def left_4_callback(msg):
    global left_4
    left_4 = msg.data
def left_5_callback(msg):
    global left_5
    left_5 = msg.data

# Head
def head_callback(msg):
    global head
    head = msg.data

if __name__ == '__main__':
    initialize_motor(DXL2_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL3_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL4_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL5_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL6_ID) #Enter Motor ID to enable torque and add parameter storage

    initialize_motor(DXL8_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL9_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL10_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL11_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL12_ID) #Enter Motor ID to enable torque and add parameter storage

    initialize_motor(DXL15_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL16_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL17_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL18_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL19_ID) #Enter Motor ID to enable torque and add parameter storage

    initialize_motor(DXL20_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL21_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL22_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL23_ID) #Enter Motor ID to enable torque and add parameter storage
    initialize_motor(DXL24_ID) #Enter Motor ID to enable torque and add parameter storage

    initialize_motor(DXL25_ID) #Enter Motor ID to enable torque and add parameter storage

    rospy.init_node('motor_setup', anonymous=True)
    rospy.Subscriber("rotation_angle_r", Float64, rotation_r_callback)
    rospy.Subscriber("abduction_angle_r", Float64, abduction_r_callback)
    rospy.Subscriber("hip_angle_r", Float64, hip_r_callback)
    rospy.Subscriber("knee_angle_r", Float64, knee_r_callback)
    rospy.Subscriber("ankle_angle_r", Float64, ankle_r_callback)
    rospy.Subscriber("ankle_twist_angle_r", Float64, ankle_twist_r_callback)

    rospy.Subscriber("rotation_angle_l", Float64, rotation_l_callback)
    rospy.Subscriber("abduction_angle_l", Float64, abduction_l_callback)
    rospy.Subscriber("hip_angle_l", Float64, hip_l_callback)
    rospy.Subscriber("knee_angle_l", Float64, knee_l_callback)
    rospy.Subscriber("ankle_angle_l", Float64, ankle_l_callback)
    rospy.Subscriber("ankle_twist_angle_l", Float64, ankle_twist_l_callback)

    rospy.Subscriber("right_1", Float64, right_1_callback)
    rospy.Subscriber("right_2", Float64, right_2_callback)
    rospy.Subscriber("right_3", Float64, right_3_callback)
    rospy.Subscriber("right_4", Float64, right_4_callback)
    rospy.Subscriber("right_5", Float64, right_5_callback)

    rospy.Subscriber("left_1", Float64, left_1_callback)
    rospy.Subscriber("left_2", Float64, left_2_callback)
    rospy.Subscriber("left_3", Float64, left_3_callback)
    rospy.Subscriber("left_4", Float64, left_4_callback)
    rospy.Subscriber("left_5", Float64, left_5_callback)

    rospy.Subscriber("head", Float64, head_callback)

    run_motor(DXL2_ID, constrain(2036, DXL2_ID))
    run_motor(DXL3_ID, constrain(2036, DXL3_ID))
    run_motor(DXL4_ID, constrain(2036, DXL4_ID))
    run_motor(DXL5_ID, constrain(2036, DXL5_ID))
    run_motor(DXL6_ID, constrain(2036, DXL6_ID))

    run_motor(DXL8_ID, constrain(2036, DXL2_ID))
    run_motor(DXL9_ID, constrain(2036, DXL3_ID))
    run_motor(DXL10_ID, constrain(2036, DXL4_ID))
    run_motor(DXL11_ID, constrain(2036, DXL5_ID))
    run_motor(DXL12_ID, constrain(2036, DXL6_ID))

    run_motor(DXL19_ID, right_1)
    run_motor(DXL20_ID, right_2 + 20)
    run_motor(DXL21_ID, right_3)
    run_motor(DXL22_ID, right_4)
    run_motor(DXL23_ID, right_5)

    run_motor(DXL15_ID, left_1 + 25)
    run_motor(DXL16_ID, left_2 + 100)
    run_motor(DXL17_ID, left_3)
    run_motor(DXL18_ID, left_4)
    run_motor(DXL24_ID, left_5)

    run_motor(DXL25_ID, head)

    rate = rospy.Rate(1000)

while not rospy.is_shutdown():
    # print (abduction_right, ankle_twist_right, abduction_left, ankle_twist_left)

    run_motor(DXL2_ID, constrain(abduction_right, DXL2_ID))
    run_motor(DXL3_ID, constrain(hip_right, DXL3_ID))
    run_motor(DXL4_ID, constrain(knee_right, DXL4_ID))
    run_motor(DXL5_ID, constrain(ankle_right, DXL5_ID))
    run_motor(DXL6_ID, constrain(ankle_twist_right, DXL6_ID))

    run_motor(DXL8_ID, constrain(abduction_left, DXL8_ID))
    run_motor(DXL9_ID, constrain(hip_left, DXL9_ID))
    run_motor(DXL10_ID, constrain(knee_left, DXL10_ID))
    run_motor(DXL11_ID, constrain(ankle_left, DXL11_ID))
    run_motor(DXL12_ID, constrain(ankle_twist_left, DXL12_ID))

    run_motor(DXL19_ID, right_1)
    run_motor(DXL20_ID, right_2 + 20)
    run_motor(DXL21_ID, right_3)
    run_motor(DXL22_ID, right_4)
    run_motor(DXL23_ID, right_5)

    run_motor(DXL15_ID, left_1 + 25)
    run_motor(DXL16_ID, left_2 + 100)
    run_motor(DXL17_ID, left_3)
    run_motor(DXL18_ID, left_4)
    run_motor(DXL24_ID, left_5)

    run_motor(DXL25_ID, head)

    # print abduction_right, hip_right, knee_right, ankle_right, ankle_twist_right, abduction_left, hip_left, knee_left, ankle_left, ankle_twist_left

    rate.sleep()

    if (rospy.is_shutdown()):
        # torque_diable(DXL2_ID)
        # torque_diable(DXL3_ID)
        # torque_diable(DXL4_ID)
        # torque_diable(DXL5_ID)
        # torque_diable(DXL6_ID)
        #
        # torque_diable(DXL8_ID)
        # torque_diable(DXL9_ID)
        # torque_diable(DXL10_ID)
        # torque_diable(DXL11_ID)
        # torque_diable(DXL12_ID)

        # torque_diable(DXL15_ID)
        # torque_diable(DXL16_ID)
        # torque_diable(DXL17_ID)
        # torque_diable(DXL18_ID)
        # torque_diable(DXL19_ID)
        #
        # torque_diable(DXL20_ID)
        # torque_diable(DXL21_ID)
        # torque_diable(DXL22_ID)
        # torque_diable(DXL23_ID)
        # torque_diable(DXL24_ID)
        #
        # torque_diable(DXL25_ID)

        print("Shutting down. Motor torque disabled.")

        portHandler.closePort()   # Close port
        print("Port Closed")

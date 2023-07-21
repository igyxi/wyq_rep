up_down_log_id              int             主键
account_id                  int             会员id
account_number              string          会员卡号
points_earned               decimal(20,5)   当前总获得的积分
account_balance             decimal(20,5)   当前剩余积分
card_type                   string          卡类别
start_card_type_time        datetime        此卡类别持续的时间从
end_card_type_time          datetime        此卡类别持续的时间止
type                        int             1-升级  2-降级
downgrade_time              datetime        升降级时间
downgrade_balance           decimal(20,5)   当时升降级积分
create_time                 datetime        
setting_time                datetime        
timestamp                   timestamp       
from_card_type              string          
dt                          string 
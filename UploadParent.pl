#===================================================================
#    データベースへのアップロード
#-------------------------------------------------------------------
#        (C) 2019 @white_mns
#===================================================================

# モジュール呼び出し    ---------------#
require "./source/Upload.pm";
require "./source/lib/time.pm";

# パッケージの使用宣言    ---------------#
use strict;
use warnings;
require LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;

# 変数の初期化    ---------------#
use ConstData_Upload;        #定数呼び出し

my $timeChecker = TimeChecker->new();

# 実行部    ---------------------------#
$timeChecker->CheckTime("start  \t");

&Main;

$timeChecker->CheckTime("end    \t");
$timeChecker->OutputTime();
$timeChecker = undef;

# 宣言部    ---------------------------#

sub Main {
    my $result_no = $ARGV[0];
    my $generate_no = $ARGV[1];
    my $upload = Upload->new();

    if (!defined($result_no) || !defined($generate_no) || $result_no !~ /^[0-9]+$/ || $generate_no !~ /^[0-9]+$/) {
        print "Error:Unusual ResultNo or GenerateNo\n";
        return;
    }

    $upload->DBConnect();
    
    $upload->DeleteSameResult("uploaded_checks", $result_no, $generate_no);

    if (ConstData::EXE_DATA) {
        &UploadData($upload, ConstData::EXE_DATA_PROPER_NAME,     "proper_names",     "./output/data/proper_name.csv");
        &UploadData($upload, ConstData::EXE_DATA_SKILL_DATA,      "skill_data",       "./output/data/skill_data.csv");
        &UploadData($upload, ConstData::EXE_DATA_LEARNABLE_SKILL, "learnable_skills", "./output/data/learnable_skill.csv");
    }
    if (ConstData::EXE_CHARA) {
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_NAME,              "names",             "./output/chara/name_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_PROFILE,           "profiles",          "./output/chara/profile_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_STATUS,            "statuses",          "./output/chara/status_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_ITEM,              "items",             "./output/chara/item_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_SKILL,             "skills",            "./output/chara/skill_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_EVENT,             "events",            "./output/chara/event_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_EVENT_PROCEED,     "event_proceeds",    "./output/chara/event_proceed_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_CHARA_SEARCH,            "searches",          "./output/chara/search_");
    }
    if (ConstData::EXE_BATTLE) {
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_BATTLE_PARTY,            "parties",           "./output/battle/party_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_BATTLE_PARTY_INFO,       "party_infos",       "./output/battle/party_info_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_BATTLE_CURRENT_PLACE,    "current_places",    "./output/battle/current_place_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_BATTLE_ITEM_GET,         "item_gets",         "./output/battle/item_get_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_BATTLE_ENEMY_PARTY_INFO, "enemy_party_infos", "./output/battle/enemy_party_info_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_BATTLE_ENEMY,            "enemies",           "./output/battle/enemy_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_BATTLE_RESULT,           "battle_results",    "./output/battle/battle_result_");
    }
    if (ConstData::EXE_NEW) {
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_NEW_EVENT,               "new_events",        "./output/new/event_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_NEW_PLACE,               "new_places",        "./output/new/place_");
        &UploadResult($upload, $result_no, $generate_no, ConstData::EXE_NEW_ENEMY,               "new_enemies",       "./output/new/enemy_");
    }
        &UploadResult($upload, $result_no, $generate_no, 1,                            "uploaded_checks", "./output/etc/uploaded_check_");
    print "result_no:$result_no,generate_no:$generate_no\n";
    return;
}

#-----------------------------------#
#       結果番号に依らないデータをアップロード
#-----------------------------------#
#    引数｜アップロードオブジェクト
#    　　　アップロード定義
#          テーブル名
#          ファイル名
##-----------------------------------#
sub UploadData {
    my ($upload, $is_upload, $table_name, $file_name) = @_;

    if ($is_upload) {
        $upload->DeleteAll($table_name);
        $upload->Upload($file_name, $table_name);
    }
}

#-----------------------------------#
#       更新結果データをアップロード
#-----------------------------------#
#    引数｜アップロードオブジェクト
#    　　　更新番号
#    　　　再更新番号
#    　　　アップロード定義
#          テーブル名
#          ファイル名
##-----------------------------------#
sub UploadResult {
    my ($upload, $result_no, $generate_no, $is_upload, $table_name, $file_name) = @_;

    if($is_upload) {
        $upload->DeleteSameResult($table_name, $result_no, $generate_no);
        $upload->Upload($file_name . $result_no . "_" . $generate_no . ".csv", $table_name);
    }
}

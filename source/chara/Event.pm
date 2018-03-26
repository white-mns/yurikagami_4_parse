#===================================================================
#        イベントフラグ取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Event;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  my %datas = ();
  
  bless {
        Datas        => \%datas,
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{EventFlag}       = StoreData->new();
    
    my $header_list = "";
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "sub_no",
                "event",
                "flag",
                "text",
    ];
    $self->{Datas}{EventFlag}->Init($header_list);
    $self->{Datas}{EventFlag}->SetOutputName( "./output/chara/event_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );

    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,サブキャラ番号,イベントノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $sub_no  = shift;
    my $evnt_div_node = shift;
    
    if($sub_no > 0) {return;} # サブキャラにイベント情報はないため処理しない
    
    $self->{ENo}   = $e_no;
    $self->{SubNo} = $sub_no;

    $self->GetItemData($evnt_div_node);
    
    return;
}
#-----------------------------------#
#    イベントデータ取得
#------------------------------------
#    引数｜イベントノード
#-----------------------------------#
sub GetItemData{
    my $self  = shift;
    my $evnt_div_node = shift;

    my $event_table_nodes = &GetNode::GetNode_Tag_Class("table","event", \$evnt_div_node);
    my $tr_nodes = &GetNode::GetNode_Tag("tr", \$$event_table_nodes[0]);
    shift(@$tr_nodes);
   
    foreach my $tr_node (@$tr_nodes){
        my @td_nodes = $tr_node->content_list();
        my ($event, $flag, $text)
         = (0,0);

        if(scalar(@td_nodes) < 3){ next;}

        $event = $self->{CommonDatas}{ProperName}->GetOrAddId($td_nodes[0]->as_text);
        $flag  = $self->{CommonDatas}{ProperName}->GetOrAddId($td_nodes[1]->as_text);
        $text  = $self->{CommonDatas}{ProperName}->GetOrAddId($td_nodes[2]->as_text);
        
        my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $self->{SubNo}, $event, $flag, $text);
        $self->{Datas}{EventFlag}->AddData(join(ConstData::SPLIT, @datas));
    }

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;

#===================================================================
#        PC名取得パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
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
package Name;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init{
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "sub_no",
                "name",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/name_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,サブキャラ番号,ステータステーブルノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $sub_no  = shift;
    my $stat_table_node = shift;
    
    $self->{ENo} = $e_no;
    $self->{SubNo} = $sub_no;

    $self->GetNameData($stat_table_node);
    
    return;
}
#-----------------------------------#
#    名前データ取得
#------------------------------------
#    引数｜ステータステーブルノード
#-----------------------------------#
sub GetNameData{
    my $self  = shift;
    my $stat_table_node = shift;
    my $name = "";
 
    my $sttitle_nodes  = &GetNode::GetNode_Tag_Attr("td", "class", "sttitle", \$stat_table_node);
    my $b_nodes        = &GetNode::GetNode_Tag("b", \$$sttitle_nodes[0]);

    $name = $$b_nodes[0]->as_text;

    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $self->{SubNo}, $name) ));

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;

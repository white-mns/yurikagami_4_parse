#===================================================================
#        戦闘結果解析パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;


require "./source/lib/IO.pm";
require "./source/lib/time.pm";

require "./source/battle/Party.pm";
require "./source/battle/PartyInfo.pm";
require "./source/battle/CurrentPlace.pm";
require "./source/battle/ItemGet.pm";
require "./source/battle/Enemy.pm";
require "./source/battle/BattleResult.pm";
require "./source/battle/Smith.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package Battle;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class        = shift;

  bless {
    Datas         => {},
    DataHandlers  => {},
    Methods       => {},
    ResultNo      => "",
    GenerateNo    => "",
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init{
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;

    #インスタンス作成
    if (ConstData::EXE_BATTLE_PARTY)         {$self->{DataHandlers}{Party}        = Party->new();}
    if (ConstData::EXE_BATTLE_PARTY_INFO)    {$self->{DataHandlers}{PartyInfo}    = PartyInfo->new();}
    if (ConstData::EXE_BATTLE_CURRENT_PLACE) {$self->{DataHandlers}{CurrentPlace} = CurrentPlace->new();}
    if (ConstData::EXE_BATTLE_ITEM_GET)      {$self->{DataHandlers}{ItemGet}      = ItemGet->new();}
    if (ConstData::EXE_BATTLE_ENEMY)         {$self->{DataHandlers}{Enemy}        = Enemy->new();}
    if (ConstData::EXE_BATTLE_RESULT)        {$self->{DataHandlers}{BattleResult} = BattleResult->new();}
    if (ConstData::EXE_BATTLE_SMITH)         {$self->{DataHandlers}{Smith}        = Smith->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});
    }
    
    return;
}

#-----------------------------------#
#    圧縮結果から戦闘データファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;

    print "read files...\n";

    my $start = 1;
    my $end   = 0;
    my $directory = './data/utf/turn' . $self->{ResultNo} . '_' . $self->{GenerateNo};
    if (ConstData::EXE_ALLRESULT) {
        #結果全解析
        $end = GetMaxFileNo($directory,"result");

    } else {
        #指定範囲解析
        $start = ConstData::FLAGMENT_START;
        $end   = ConstData::FLAGMENT_END;
    }

    print "$start to $end\n";

    for (my $party_no=$start; $party_no<=$end; $party_no++) {
        if($party_no % 10 == 0){print $party_no . "\n"};

        $self->ParsePage($directory."/result".$party_no.".html",$party_no );
    }
    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　パーティ番号
##-----------------------------------#
sub ParsePage{
    my $self      = shift;
    my $file_name = shift;
    my $party_no  = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::FileRead($file_name);
    $content =~ s/&copy;/"©"/ge;
    $content =~ s/&reg;/"®"/ge;

    if (!$content) { return;}

    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $stat_table_nodes     = &GetNode::GetNode_Tag_Attr("table", "class", "stat",      \$tree);
    my $h1_nodes             = &GetNode::GetNode_Tag("h1", \$tree);
    my $bstat_table_nodes    = &GetNode::GetNode_Tag_Attr("table", "class", "bstat",     \$tree);
    my $map_div_nodes        = &GetNode::GetNode_Tag_Attr("div",   "class", "map",       \$tree);
    my $quest_div_nodes      = &GetNode::GetNode_Tag_Attr("div",   "class", "quest",     \$tree);
    my $item_get_div_nodes   = &GetNode::GetNode_Tag_Attr("div",   "class", "item get",  \$tree);
    my $finish_div_nodes     = &GetNode::GetNode_Tag_Attr("div",   "class", "finish",    \$tree);
    my $battle_div_nodes     = &GetNode::GetNode_Tag_Attr("div",   "class", "battle",    \$tree);
    my $smith_div_nodes      = &GetNode::GetNode_Tag_Attr("div",   "class", "smith get", \$tree);
    
    # データリスト取得
    if (exists($self->{DataHandlers}{Party}))        {$self->{DataHandlers}{Party}->GetData       ($party_no, $stat_table_nodes)};
    if (exists($self->{DataHandlers}{PartyInfo}))    {$self->{DataHandlers}{PartyInfo}->GetData   ($party_no, $$h1_nodes[0], $$bstat_table_nodes[0])};
    if (exists($self->{DataHandlers}{CurrentPlace})) {$self->{DataHandlers}{CurrentPlace}->GetData($party_no, $$map_div_nodes[0])};
    if (exists($self->{DataHandlers}{ItemGet}))      {$self->{DataHandlers}{ItemGet}->GetData     ($party_no, $item_get_div_nodes, $$quest_div_nodes[0])};
    if (exists($self->{DataHandlers}{Enemy}))        {$self->{DataHandlers}{Enemy}->GetData       ($party_no, $bstat_table_nodes, $$quest_div_nodes[0])};
    if (exists($self->{DataHandlers}{BattleResult})) {$self->{DataHandlers}{BattleResult}->GetData($party_no, $$finish_div_nodes[0], $$battle_div_nodes[0], $$quest_div_nodes[0])};
    if (exists($self->{DataHandlers}{Smith}))        {$self->{DataHandlers}{Smith}->GetData       ($party_no, $smith_div_nodes)};

    $tree = $tree->delete;
}

#-----------------------------------#
#       最大ファイル番号を取得
#-----------------------------------#
#    引数｜ディレクトリ名
#    　　　ファイル接頭辞
##-----------------------------------#
sub GetMaxFileNo{
    my $directory   = shift;
    my $prefix    = shift;

    #ファイル名リストを取得
    my @fileList = grep { -f } glob("$directory/$prefix*.html");

    my $max= 0;
    foreach (@fileList) {
        $_ =~ /$prefix(\d+).html/;
        if ($max < $1) {$max = $1;}
    }
    return $max
}

#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output{
    my $self = shift;
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Output();
    }
    return;
}

1;

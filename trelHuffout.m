for i=1:sNo
    codelen=[];
    for j=1:trellis(i).outNo
        codelen(j)=length(trellis(i).out(j).code);
    end
    prob=2.^(-codelen);
    prob=prob/sum(prob);
    [dict,avglen] = huffmandict(1:trellis(i).outNo,prob); % Create dictionary.
    for j=1:trellis(i).outNo
        trellis(i).Huffout(j).code=dict{j,2};
    end
end
disp('Huffman trellis')
sh=input('Show in >> out ?','s');
if sh=='y'
    clc
    for i=1:sNo
        for j=1:trellis(i).outNo
            disp([int2str(trellis(i).in(j).code),'                   >>                           ',int2str(trellis(i).Huffout(j).code)])
        end
        disp('========================')
    end
end
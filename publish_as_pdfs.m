% Publish all files *.m as PDF files.

m_files = dir("*.m");
for j = 1:size(m_files, 1)
    in_file = m_files(j).name;
    if in_file ~= "publish_as_pdfs.m"
        display(in_file);
        publish(in_file, format="pdf", evalCode=false);
    end
end
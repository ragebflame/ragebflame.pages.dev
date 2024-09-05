+++
title = "Scraping PDFs from Flipsnack"
date = 2022-09-19

[taxonomies]
tags = ["bash", "linux", "python"]
+++

{{ image(src="/img/computers/office.webp", alt="An impressionist landscape of a computer in an office cubicle surrounded by stacks of paper, abandoned, interior.",
         position="center", style="border-radius: 4px;") }}

[Flipsnack](https://www.flipsnack.com/) is a service which allows you to upload PDFs and serve them as a flip book widget.

> Create, share and embed online page flip catalogs, transforming your PDFs into online flipping books. Make a flip book online using our advanced flip book maker.

This is all well and good, but what if you want to download the content? Here is a _hacky_ way to do that.

I run all of these steps within an Ubuntu [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) environment. What we are going to do:

1. Identify the CDN URL.
2. Download each of the pages as _JPG_ images.
3. Rename the downloaded files to ensure the PDF output page order is correct.
4. Convert to PDF.
5. **Bonus:** Make the text selectable within the PDF.

The first thing you'll want to do is grab the URL for the PDF you are looking to download. You can grab this using Dev tools in your browser and having a look at the Sources. The URL will have a structure containing a `UNIQUE_ID` and `HASH_VALUE`. Also notice the `PAGE_NUMBER`. Take note of the last available page as it'll be needed when downloading.

```txt
https://cdn.flipsnack.com/collections/items/<UNIQUE_ID>/covers/page_<PAGE_NUMBER>/original?v=<HASH_VALUE>
```

Now let's install the tools we need.

```bash
# Install the needed components
# Assuming Python 3+ is already installed
sudo apt install curl rename tesseract-ocr -y
pip install ocrmypdf
```

Next, we are going to use `curl` to download each of the images (pages) as JPGs. Here is where you want to pass in the page range. In this case, the PDF had 162 pages.

```bash
# Grab the images
curl https://cdn.flipsnack.com/collections/items/<UNIQUE_ID>/covers/page_\[1-162\]/original\?v\=<HASH_VALUE> -o "#1.jpg"
```

Once finished, you should now have a directory full of images, each of which is a page of the PDF.

```txt
├── 10.jpg
├── 11.jpg
├── 12.jpg
├── 13.jpg
├── 14.jpg
├── 15.jpg
├── 16.jpg
├── 17.jpg
├── 18.jpg
├── 19.jpg
├── 1.jpg
├── 20.jpg
├── 21.jpg
...
```

Since the order of images is incorrect, let's add some leading zeros to the filenames using `rename`.

```bash
# Add 3 leading zeros to the filenames
rename 's/\d+/sprintf("%03d",$&)/e' *.jpg
```

That's better.

```txt
├── 001.jpg
├── 002.jpg
├── 003.jpg
├── 004.jpg
├── 005.jpg
├── 006.jpg
├── 007.jpg
├── 008.jpg
├── 009.jpg
├── 010.jpg
├── 011.jpg
├── 012.jpg
├── 013.jpg
├── 014.jpg
├── 015.jpg
├── 016.jpg
├── 017.jpg
├── 018.jpg
├── 019.jpg
├── 020.jpg
├── 021.jpg
...
```

Time to merge these images into a PDF using the Python module [img2pdf](https://pypi.org/project/img2pdf/)

```bash
# Merge and convert to PDF
python3 -m img2pdf *.jp* --output combined.pdf
```

As a final step, we can use the [ocrmypdf](https://pypi.org/project/ocrmypdf/) module to add an OCR text layer to the PDF. This allows text to be searched or copy-pasted. This can take some time depending on the size of the PDF, so let it do its thing.

```bash
# Add OCR layer to PDF
python3 -m ocrmypdf combined.pdf combined_ocr.pdf
```

---

And with that, you have an offline copy of the PDF. There might be a much easier way of going about this, but it was a good excuse to play around with some tools.

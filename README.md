# BibTex Cleaner 
This is just a little tool to clean up your BibTeX `.bib` file.

The idea is to turn this:
```BibTex
@inproceedings{10.1145/3341162.3349306, author = {Marini, Gabriele},
title = {Towards Indoor Localisation Analytics for Modelling Flows of Movements},
booktitle = {whbatevas},
pages = {377–382},
}

@Article{info:doi/10.2196/19874, author="Marini, Gabriele and Tag, Benjamin and Goncalves, Jorge and Velloso, Eduardo and Jurdak, Raja and Capurro, Daniel and McCarthy, Clare and Shearer, William and Kostakos, Vassilis",
title="Measuring Mobility and Room Occupancy in Clinical Settings: System Development and Implementation",
number="10",
pages="e19874",
keywords="localization; indoor; efficiency; Bluetooth; occupancy; mobility; metrics; smartphone; mobile phone",
}
```


Into this:
```BibTex
@InProceedings{Marini_2019,
    author		= {Gabriele Marini},
    title		= {Towards indoor localisation analytics for modelling flows of movements},
    booktitle	= {Adjunct Proceedings of the 2019 ACM International Joint Conference on Pervasive and Ubiquitous Computing and Proceedings of the 2019 ACM International Symposium on Wearable Computers},
    pages		= {377–382},
    doi			= {10.1145/3341162.3349306},
    url			= {https://doi.org/10.1145/3341162.3349306},
    year		= {2019},
    month		= {sep},
    publisher	= {ACM},
    r_updated	= {YES},
}
@Article{Marini_2020,
    author		= {Gabriele Marini and Benjamin Tag and Jorge Goncalves and Eduardo Velloso and Raja Jurdak and Daniel Capurro and Clare McCarthy and William Shearer and Vassilis Kostakos},
    title		= {Measuring Mobility and Room Occupancy in Clinical Settings: System Development and Implementation (Preprint)},
    pages		= {e19874},
    doi			= {10.2196/preprints.19874},
    url			= {https://doi.org/10.2196/preprints.19874},
    year		= {2020},
    month		= {may},
    publisher	= {JMIR Publications Inc.},
    number		= {10},
    keywords		= {localization; indoor; efficiency; Bluetooth; occupancy; mobility; metrics; smartphone; mobile phone},
    r_updated	= {YES},
}
```

## Features
- DOI lookup from title through `rcrossref` and `aRxiv`
```R
title <- "Towards indoor localisation analytics for modelling flows of movements"
resCR <- cr_works(query = title, format = "text", style = "acm", limit=10) 
resArxiv <- arxiv_search(query = noquote(paste0('ti:\"', title, '\"')), limit=10)
```

- Metadata update from DOI through `rcrossref`
```R
style <- "acm>
cr_cn(dois = doi, format = "bibtex", style=style, locale="en-US") 
```
- **Multi-Threaded**
- Only updates data if titles are similar
- Keeps all the extra metadatata already in the bibentry (including abstracts)
- Outputs to file AND also returns a `data.table` (`data.frame`)
- Sort result by key (e.g by title or year)
- Updated entries are marked with:
```BibTex
r_updated = {YES}
```

## Instructions
0. Clone the repository
1. Install all the required libraries by running `lib_install.R` (need R >= 3.6)
2. Open `clean_refs.R`, edit path, options and filename
3. Call 
```R
bib_df <- updateReferences(..., multithreaded = TRUE)
```
Multithreaded is highly recommended
4. The output will already be written in `out_file` but you can check the resulting `df` for any missing data
5. Use `CTRL+F` on the output file and look for `{NO}` to double check the entries that have not been updated

## Options
- `upd_bibkey`: Whether to updated the bibkey or not. The bibkey is the identifier at the beginning of the ref. E.g. `Marini_2019` is the bibkey here:
```BibTex
@InProceedings{Marini_2019,
    author		= {Gabriele Marini},
    title		= {Towards indoor localisation analytics for modelling flows of movements},
    booktitle	= {Adjunct Proceedings of the 2019 ACM International Joint Conference on Pervasive and Ubiquitous Computing and Proceedings of the 2019 ACM International Symposium on Wearable Computers},
    ...,
    r_updated	= {YES},
}
```
If you have already cited your work in your LaTeX I'd leave this as `FALSE` so you won't need to updated your `\cite{...}` in LaTeX

- `upd_author`: Whether to updated the list of authors or not (useful when changing the reference style)

-`upd_title`: Whether to update the title or not. Some works might have different titles online. For instance looking up this work's DOI:

```BibTeX
@InProceedings{kubitza2013webclip:1,
    title		= {WebClip: a connector for ubiquitous physical input and output for touch screen devices},
    author		= {Thomas Kubitza and Norman Pohl and Tilman Dingler and Albrecht Schmidt},
    doi			= {10.1145/2493432.2493520},
    url			= {https://doi.org/10.1145/2493432.2493520},
    ...
    r_updated	= {YES},
}
```

Will return a citation whose title is "WebClip". In this case it might be a good idea to keep the original title.

- `sorting_key`: The key to use to sort the references before outputting to file. If `NULL` or `file` it will follow the input file's order
-`decreasing`: Sorting order based on the key above (won't work if sorting key is null or file)
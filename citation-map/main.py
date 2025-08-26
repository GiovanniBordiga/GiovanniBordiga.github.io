from citation_map import generate_citation_map

if __name__ == '__main__':
    # This is my Google Scholar ID. Replace this with your ID.
    scholar_id = 'RR1ZhI0AAAAJ'
    generate_citation_map(
        scholar_id=scholar_id,
        output_path="assets/html/citation_map.html",
        csv_output_path="citation-map/citation_map.csv",
        cache_folder="citation-map/cache",
        # affiliation_conservative=True,
    )

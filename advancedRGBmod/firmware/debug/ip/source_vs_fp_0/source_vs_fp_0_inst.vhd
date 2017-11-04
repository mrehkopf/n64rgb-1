	component source_vs_fp_0 is
		port (
			source : out std_logic_vector(3 downto 0)   -- source
		);
	end component source_vs_fp_0;

	u0 : component source_vs_fp_0
		port map (
			source => CONNECTED_TO_source  -- sources.source
		);


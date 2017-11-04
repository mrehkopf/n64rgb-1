	component source_hend_0 is
		port (
			source : out std_logic_vector(10 downto 0)   -- source
		);
	end component source_hend_0;

	u0 : component source_hend_0
		port map (
			source => CONNECTED_TO_source  -- sources.source
		);

